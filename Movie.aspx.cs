using System;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace KumariCinemas
{
    public partial class Movie : System.Web.UI.Page
    {
        // DB helpers
        private DbConnection GetConnection()
        {
            var cs = ConfigurationManager.ConnectionStrings["ConnectionString"];
            var factory = DbProviderFactories.GetFactory(cs.ProviderName);
            var conn = factory.CreateConnection();
            conn.ConnectionString = cs.ConnectionString;
            return conn;
        }

        private DbParameter Param(string name, object value)
        {
            var cs = ConfigurationManager.ConnectionStrings["ConnectionString"];
            var factory = DbProviderFactories.GetFactory(cs.ProviderName);
            var p = factory.CreateParameter();
            p.ParameterName = name;
            p.Value = (value == null) ? (object)DBNull.Value : value;
            return p;
        }

        private void ExecuteNonQuery(string sql, params DbParameter[] parms)
        {
            using (var conn = GetConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = sql;
                    foreach (var p in parms) cmd.Parameters.Add(p);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // Reformat date parameter to YYYY-MM-DD for Oracle
        private void FixDateParam(SqlDataSourceCommandEventArgs e, string paramName)
        {
            if (!e.Command.Parameters.Contains(paramName)) return;
            string raw = e.Command.Parameters[paramName].Value?.ToString();
            if (string.IsNullOrWhiteSpace(raw)) return;
            string[] fmts = { "dd-MMM-yy", "dd-MMM-yyyy", "dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd", "d-MMM-yyyy", "dd-MM-yyyy" };
            DateTime dt;
            if (DateTime.TryParseExact(raw, fmts, System.Globalization.CultureInfo.InvariantCulture,
                    System.Globalization.DateTimeStyles.None, out dt) || DateTime.TryParse(raw, out dt))
                e.Command.Parameters[paramName].Value = dt.ToString("yyyy-MM-dd");
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
        }

        protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e) { }

        protected void SqlDataSource1_Inserted(object sender, SqlDataSourceStatusEventArgs e)
        {
            if (e.Exception != null && e.Exception.Message.Contains("ORA-00001"))
            {
                ShowMsg("Error: Movie ID already exists. Please choose a different ID.", "danger");
                e.ExceptionHandled = true;
            }
        }

        // Fix date format on inline edit
        protected void SqlDataSource1_Updating(object sender, SqlDataSourceCommandEventArgs e)
        {
            FixDateParam(e, "RELEASE_DATE");
        }

        // Cascade delete
        protected void SqlDataSource1_Deleting(object sender, SqlDataSourceCommandEventArgs e)
        {
            int movieId = Convert.ToInt32(e.Command.Parameters["MOVIE_ID"].Value);
            try
            {
                ExecuteNonQuery(
                    "DELETE FROM \"TICKET\" WHERE \"TICKET_ID\" IN " +
                    "(SELECT \"TICKET_ID\" FROM \"SHOW_TICKET\" WHERE \"MOVIE_ID\" = :ID)",
                    Param("ID", movieId));
                ExecuteNonQuery("DELETE FROM \"SHOW_TICKET\"    WHERE \"MOVIE_ID\" = :ID", Param("ID", movieId));
                ExecuteNonQuery("DELETE FROM \"HALL_SHOW\"      WHERE \"MOVIE_ID\" = :ID", Param("ID", movieId));
                ExecuteNonQuery("DELETE FROM \"CUSTOMER_MOVIE\" WHERE \"MOVIE_ID\" = :ID", Param("ID", movieId));
                ExecuteNonQuery("DELETE FROM \"MOVIE_THEATRE\"  WHERE \"MOVIE_ID\" = :ID", Param("ID", movieId));
            }
            catch (Exception ex)
            {
                ShowMsg("Error removing linked records: " + ex.Message, "danger");
                e.Command.CommandText = "SELECT 1 FROM DUAL";
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
