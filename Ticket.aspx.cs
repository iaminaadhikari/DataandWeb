using System;
using System.Configuration;
using System.Data;
using System.Data.OracleClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace KumariCinemas
{
    public partial class Ticket : System.Web.UI.Page
    {
        // DB helpers
        private string CS
        {
            get { return ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString; }
        }


        private void Run(string sql, params object[] values)
        {
            using (var conn = new OracleConnection(CS))
            {
                conn.Open();
                using (var cmd = new OracleCommand(sql, conn))
                {
                    for (int i = 0; i < values.Length; i++)
                        cmd.Parameters.Add((i + 1).ToString(), values[i] ?? (object)DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }


        private DataTable Query(string sql, params object[] values)
        {
            var dt = new DataTable();
            using (var conn = new OracleConnection(CS))
            {
                conn.Open();
                using (var cmd = new OracleCommand(sql, conn))
                {
                    for (int i = 0; i < values.Length; i++)
                        cmd.Parameters.Add((i + 1).ToString(), values[i] ?? (object)DBNull.Value);
                    using (var da = new OracleDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
            return dt;
        }

        // Reformat date parameter to YYYY-MM-DD for Oracle
        private void FixDateParam(SqlDataSourceCommandEventArgs e, string paramName)
        {
            if (!e.Command.Parameters.Contains(paramName)) return;
            string raw = e.Command.Parameters[paramName].Value?.ToString();
            if (string.IsNullOrWhiteSpace(raw)) return;
            string[] fmts = { "dd-MMM-yy","dd-MMM-yyyy","dd/MM/yyyy","MM/dd/yyyy",
                              "yyyy-MM-dd","d-MMM-yyyy","dd-MM-yyyy" };
            DateTime dt;
            if (DateTime.TryParseExact(raw, fmts,
                    System.Globalization.CultureInfo.InvariantCulture,
                    System.Globalization.DateTimeStyles.None, out dt)
                || DateTime.TryParse(raw, out dt))
                e.Command.Parameters[paramName].Value = dt.ToString("yyyy-MM-dd");
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
        }

        // Show insert form
        protected void btnShowForm_Click(object sender, EventArgs e)
        {
            FormView1.ChangeMode(FormViewMode.Insert);
            LoadDropdowns();
            btnShowForm.Visible = false;
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (FormView1.CurrentMode == FormViewMode.Insert)
            {
                btnShowForm.Visible = false;
                LoadDropdowns();
            }
            else
            {
                btnShowForm.Visible = true;
            }
        }

        protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e) { }

        // Fix date format on inline edit
        protected void SqlDataSource1_Updating(object sender, SqlDataSourceCommandEventArgs e)
        {
            FixDateParam(e, "BOOKING_TIME");
            string purchaseRaw = e.Command.Parameters["PURCHASE_TIME"].Value?.ToString();
            if (string.IsNullOrWhiteSpace(purchaseRaw))
                e.Command.CommandText = e.Command.CommandText.Replace(
                    "TO_DATE(:PURCHASE_TIME,'YYYY-MM-DD')", "NULL");
            else
                FixDateParam(e, "PURCHASE_TIME");
        }

        // Cascade delete Ticket
        protected void SqlDataSource1_Deleting(object sender, SqlDataSourceCommandEventArgs e)
        {
            int ticketId = Convert.ToInt32(e.Command.Parameters["TICKET_ID"].Value);
            try
            {
                Run("DELETE FROM \"SHOW_TICKET\" WHERE \"TICKET_ID\" = :1", ticketId);
            }
            catch (Exception ex)
            {
                ShowMsg("Error removing linked records: " + ex.Message, "danger");
                e.Command.CommandText = "SELECT 1 FROM DUAL";
            }
        }

        // Load FK dropdowns
        private void LoadDropdowns()
        {
            if (FormView1.CurrentMode != FormViewMode.Insert) return;

            var ddlCustomer = FormView1.FindControl("ddlCustomer") as DropDownList;
            var ddlShow = FormView1.FindControl("ddlShow") as DropDownList;

            if (ddlCustomer != null && ddlCustomer.Items.Count == 0)
                BindDdl(ddlCustomer,
                    "SELECT \"USER_ID\", \"USERNAME\" || ' (ID:' || \"USER_ID\" || ')' AS D " +
                    "FROM \"CUSTOMER\" ORDER BY \"USERNAME\"",
                    "D", "USER_ID");

            if (ddlShow != null && ddlShow.Items.Count == 0)
                BindDdl(ddlShow,
                    "SELECT hs.\"SHOW_ID\", " +
                    "m.\"TITLE\" || ' | ' || s.\"SHOW_TIMES\" || ' | ' || " +
                    "TO_CHAR(s.\"SHOW_DATE\",'DD-Mon-YYYY') || " +
                    "' | ' || t.\"THEATRE_NAME\" || ', ' || t.\"THEATRE_CITY\" AS D " +
                    "FROM \"HALL_SHOW\" hs " +
                    "JOIN \"SHOW\"    s ON s.\"SHOW_ID\"    = hs.\"SHOW_ID\" " +
                    "JOIN \"MOVIE\"   m ON m.\"MOVIE_ID\"   = hs.\"MOVIE_ID\" " +
                    "JOIN \"THEATRE\" t ON t.\"THEATRE_ID\" = hs.\"THEATRE_ID\" " +
                    "ORDER BY s.\"SHOW_DATE\", s.\"SHOW_TIMES\"",
                    "D", "SHOW_ID");
        }

        private void BindDdl(DropDownList ddl, string sql, string textF, string valF)
        {
            var dt = Query(sql);
            ddl.DataSource = dt;
            ddl.DataTextField = textF;
            ddl.DataValueField = valF;
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("-- Select --", ""));
        }

        // Insert Ticket and Show_Ticket junction
        protected void FormView1_ItemInserting(object sender, FormViewInsertEventArgs e)
        {
            e.Cancel = true;
            try
            {
                var txtId = FormView1.FindControl("TICKET_IDTextBox") as TextBox;
                var txtPrice = FormView1.FindControl("TICKET_PRICETextBox") as TextBox;
                var txtBook = FormView1.FindControl("BOOKING_TIMETextBox") as TextBox;
                var txtPurchase = FormView1.FindControl("PURCHASE_TIMETextBox") as TextBox;
                var ddlStatus = FormView1.FindControl("PAYMENT_STATUSDropDown") as DropDownList;
                var txtSeat = FormView1.FindControl("SEAT_NUMBERTextBox") as TextBox;
                var ddlCustomer = FormView1.FindControl("ddlCustomer") as DropDownList;
                var ddlShow = FormView1.FindControl("ddlShow") as DropDownList;

                int ticketId = int.Parse(txtId.Text.Trim());
                decimal price = decimal.Parse(txtPrice.Text.Trim());
                string bookDate = txtBook.Text.Trim();
                string status = ddlStatus.SelectedValue;
                string seat = txtSeat.Text.Trim().ToUpper();
                int userId = int.Parse(ddlCustomer.SelectedValue);
                int showId = int.Parse(ddlShow.SelectedValue);

                // Validate booking date
                if (DateTime.TryParse(bookDate, out DateTime bd) && bd.Date < DateTime.Today)
                {
                    ShowMsg("Business Rule: Booking date cannot be in the past.", "warning");
                    return;
                }

                // Look up Show details and Hall_Show link
                DataTable hsRow = Query(
                    "SELECT hs.\"MOVIE_ID\", hs.\"HALL_ID\", hs.\"THEATRE_ID\", " +
                    "       s.\"SHOW_DATE\", s.\"SHOW_TIMES\" " +
                    "FROM \"HALL_SHOW\" hs " +
                    "JOIN \"SHOW\" s ON s.\"SHOW_ID\" = hs.\"SHOW_ID\" " +
                    "WHERE hs.\"SHOW_ID\" = :1 AND ROWNUM = 1",
                    showId);

                if (hsRow.Rows.Count == 0)
                {
                    ShowMsg("Error: Selected Show has no Hall_Show record. " +
                            "Please insert this Show via the Show page first.", "danger");
                    return;
                }

                int movieId = Convert.ToInt32(hsRow.Rows[0]["MOVIE_ID"]);
                int hallId = Convert.ToInt32(hsRow.Rows[0]["HALL_ID"]);
                int theatreId = Convert.ToInt32(hsRow.Rows[0]["THEATRE_ID"]);
                DateTime showDate = Convert.ToDateTime(hsRow.Rows[0]["SHOW_DATE"]);
                string showTimes = hsRow.Rows[0]["SHOW_TIMES"].ToString().Trim();

                // Map show time slot to actual hour
                int showHour;
                switch (showTimes.ToLower())
                {
                    case "morning": showHour = 10; break;
                    case "day": showHour = 14; break;
                    case "evening": showHour = 19; break;
                    default: showHour = 10; break;
                }

                DateTime showStart = new DateTime(
                    showDate.Year, showDate.Month, showDate.Day,
                    showHour, 0, 0);

                // Business rule: reject Unpaid tickets within 1 hour of show time
                if (status == "Unpaid" && DateTime.Now >= showStart.AddHours(-1))
                {
                    ShowMsg("Business Rule: Unpaid tickets cannot be booked within 1 hour of " +
                            "show time. Show starts at " + showStart.ToString("dd-MMM-yyyy HH:mm") +
                            ". Please pay for this ticket or choose a later show.", "danger");
                    return;
                }

                // Set purchase date based on payment status
                bool hasPurchase = (status == "Paid" || status == "Discounted")
                                      && !string.IsNullOrWhiteSpace(txtPurchase?.Text);
                string purchaseDate = hasPurchase ? txtPurchase.Text.Trim() : null;

                if (purchaseDate != null)
                    Run("INSERT INTO \"TICKET\" (\"TICKET_ID\",\"TICKET_PRICE\",\"BOOKING_TIME\"," +
                        "\"PURCHASE_TIME\",\"PAYMENT_STATUS\",\"SEAT_NUMBER\") " +
                        "VALUES (:1,:2,TO_DATE(:3,'YYYY-MM-DD'),TO_DATE(:4,'YYYY-MM-DD'),:5,:6)",
                        ticketId, price, bookDate, purchaseDate, status, seat);
                else
                    Run("INSERT INTO \"TICKET\" (\"TICKET_ID\",\"TICKET_PRICE\",\"BOOKING_TIME\"," +
                        "\"PURCHASE_TIME\",\"PAYMENT_STATUS\",\"SEAT_NUMBER\") " +
                        "VALUES (:1,:2,TO_DATE(:3,'YYYY-MM-DD'),SYSDATE,:4,:5)",
                        ticketId, price, bookDate, status, seat);

                // Insert Show_Ticket junction
                Run("INSERT INTO \"SHOW_TICKET\" " +
                    "(\"TICKET_ID\",\"SHOW_ID\",\"USER_ID\",\"MOVIE_ID\",\"HALL_ID\",\"THEATRE_ID\") " +
                    "VALUES (:1,:2,:3,:4,:5,:6)",
                    ticketId, showId, userId, movieId, hallId, theatreId);

                FormView1.ChangeMode(FormViewMode.ReadOnly);
                btnShowForm.Visible = true;
                GridView1.DataBind();
                ShowMsg("Ticket inserted successfully! Linked to Movie ID " + movieId +
                        ", Theatre ID " + theatreId + ", Hall ID " + hallId, "success");
            }
            catch (Exception ex) when (ex.Message.Contains("ORA-00001"))
            { ShowMsg("Error: Ticket ID already exists. Use a different ID.", "danger"); }
            catch (Exception ex) when (ex.Message.Contains("ORA-02291"))
            { ShowMsg("Error: A selected value does not exist in the database.", "danger"); }
            catch (Exception ex)
            { ShowMsg("Error: " + ex.Message, "danger"); }
        }

        protected void FormView1_ModeChanged(object sender, EventArgs e)
        {

            if (FormView1.CurrentMode == FormViewMode.Insert)
            {
                btnShowForm.Visible = false;
                LoadDropdowns();
            }
            else
            {
                btnShowForm.Visible = true;
            }
        }

        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridView1.EditIndex = e.NewEditIndex;
            GridView1.DataBind();
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridView1.EditIndex = -1;
            GridView1.DataBind();
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "alert alert-" + type;
            lblMsg.Visible = true;
        }
    }
}
