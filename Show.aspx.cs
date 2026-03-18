using System;
using System.Configuration;
using System.Data;
using System.Data.OracleClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace KumariCinemas
{
    public partial class Show : System.Web.UI.Page
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

        // Force Insert mode after all events are processed
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (FormView1.CurrentMode != FormViewMode.Insert)
                FormView1.ChangeMode(FormViewMode.Insert);
            LoadDropdowns();
        }

        protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e) { }

        // Fix date format on inline edit
        protected void SqlDataSource1_Updating(object sender, SqlDataSourceCommandEventArgs e)
        {
            FixDateParam(e, "SHOW_DATE");
        }

        // Cascade delete Show
        protected void SqlDataSource1_Deleting(object sender, SqlDataSourceCommandEventArgs e)
        {
            int showId = Convert.ToInt32(e.Command.Parameters["SHOW_ID"].Value);
            try
            {
                Run("DELETE FROM \"TICKET\" WHERE \"TICKET_ID\" IN " +
                    "(SELECT \"TICKET_ID\" FROM \"SHOW_TICKET\" WHERE \"SHOW_ID\" = :1)", showId);
                Run("DELETE FROM \"SHOW_TICKET\" WHERE \"SHOW_ID\" = :1", showId);
                Run("DELETE FROM \"HALL_SHOW\"   WHERE \"SHOW_ID\" = :1", showId);
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
            var ddlCustomer = FormView1.FindControl("ddlCustomer") as DropDownList;
            var ddlMovie = FormView1.FindControl("ddlMovie") as DropDownList;
            var ddlTheatre = FormView1.FindControl("ddlTheatre") as DropDownList;
            var ddlHall = FormView1.FindControl("ddlHall") as DropDownList;

            if (ddlCustomer != null && ddlCustomer.Items.Count == 0)
                BindDdl(ddlCustomer,
                    "SELECT \"USER_ID\", \"USERNAME\" || ' (ID:' || \"USER_ID\" || ')' AS D " +
                    "FROM \"CUSTOMER\" ORDER BY \"USERNAME\"",
                    "D", "USER_ID", "-- Select Customer --");

            if (ddlMovie != null && ddlMovie.Items.Count == 0)
                BindDdl(ddlMovie,
                    "SELECT \"MOVIE_ID\", \"TITLE\" || ' (' || \"LANGUAGE\" || ')' AS D " +
                    "FROM \"MOVIE\" ORDER BY \"TITLE\"",
                    "D", "MOVIE_ID", "-- Select Movie --");

            if (ddlTheatre != null && ddlTheatre.Items.Count == 0)
                BindDdl(ddlTheatre,
                    "SELECT \"THEATRE_ID\", \"THEATRE_CITY\" || ' - ' || \"THEATRE_NAME\" AS D " +
                    "FROM \"THEATRE\" ORDER BY \"THEATRE_CITY\"",
                    "D", "THEATRE_ID", "-- Select Theatre --");

            if (ddlHall != null && ddlHall.Items.Count == 0)
                BindDdl(ddlHall,
                    "SELECT \"HALL_ID\", 'Hall ' || \"HALL_ID\" || ' (cap: ' || \"HALL_CAPACITY\" || ')' AS D " +
                    "FROM \"HALL\" ORDER BY \"HALL_ID\"",
                    "D", "HALL_ID", "-- Select Hall --");
        }

        private void BindDdl(DropDownList ddl, string sql, string textF, string valF, string prompt)
        {
            var dt = Query(sql);
            ddl.DataSource = dt;
            ddl.DataTextField = textF;
            ddl.DataValueField = valF;
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem(prompt, ""));
        }

        // Insert Show and Hall_Show junction
        protected void FormView1_ItemInserting(object sender, FormViewInsertEventArgs e)
        {
            e.Cancel = true;
            try
            {
                var txtShowId = FormView1.FindControl("SHOW_IDTextBox") as TextBox;
                var ddlTime = FormView1.FindControl("SHOW_TIMESDropDown") as DropDownList;
                var txtDate = FormView1.FindControl("SHOW_DATETextBox") as TextBox;
                var ddlCustomer = FormView1.FindControl("ddlCustomer") as DropDownList;
                var ddlMovie = FormView1.FindControl("ddlMovie") as DropDownList;
                var ddlTheatre = FormView1.FindControl("ddlTheatre") as DropDownList;
                var ddlHall = FormView1.FindControl("ddlHall") as DropDownList;

                if (string.IsNullOrWhiteSpace(txtShowId?.Text) ||
                    string.IsNullOrWhiteSpace(ddlTime?.SelectedValue) ||
                    string.IsNullOrWhiteSpace(txtDate?.Text) ||
                    string.IsNullOrWhiteSpace(ddlCustomer?.SelectedValue) ||
                    string.IsNullOrWhiteSpace(ddlMovie?.SelectedValue) ||
                    string.IsNullOrWhiteSpace(ddlTheatre?.SelectedValue) ||
                    string.IsNullOrWhiteSpace(ddlHall?.SelectedValue))
                {
                    ShowMsg("All fields are required.", "warning");
                    return;
                }

                int showId = int.Parse(txtShowId.Text.Trim());
                string showTimes = ddlTime.SelectedValue;
                string showDate = txtDate.Text.Trim();
                int userId = int.Parse(ddlCustomer.SelectedValue);
                int movieId = int.Parse(ddlMovie.SelectedValue);
                int theatreId = int.Parse(ddlTheatre.SelectedValue);
                int hallId = int.Parse(ddlHall.SelectedValue);

                Run("INSERT INTO \"SHOW\" (\"SHOW_ID\",\"SHOW_TIMES\",\"SHOW_DATE\") " +
                    "VALUES (:1,:2,TO_DATE(:3,'YYYY-MM-DD'))",
                    showId, showTimes, showDate);

                // Insert Hall_Show junction
                Run("INSERT INTO \"HALL_SHOW\" " +
                    "(\"USER_ID\",\"MOVIE_ID\",\"THEATRE_ID\",\"HALL_ID\",\"SHOW_ID\") " +
                    "VALUES (:1,:2,:3,:4,:5)",
                    userId, movieId, theatreId, hallId, showId);

                GridView1.DataBind();
                ShowMsg("Show inserted and linked to Movie, Theatre and Hall successfully!", "success");
            }
            catch (Exception ex) when (ex.Message.Contains("ORA-00001"))
            {
                ShowMsg("Error: Show ID already exists. Use a different ID.", "danger");
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + ex.Message, "danger");
            }
        }

        private void ShowMsg(string msg, string type)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "alert alert-" + type;
            lblMsg.Visible = true;
        }
    }
}
