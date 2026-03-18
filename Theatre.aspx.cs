using System;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace KumariCinemas
{
    public partial class Theatre : System.Web.UI.Page
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


        protected void Page_Load(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
        }

        protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e) { }

        // Catch duplicate primary key — Theatre
        protected void SqlDataSource1_Inserted(object sender, SqlDataSourceStatusEventArgs e)
        {
            if (e.Exception != null && e.Exception.Message.Contains("ORA-00001"))
            {
                ShowMsg("Error: Theatre ID already exists. Please choose a different ID.", "danger");
                e.ExceptionHandled = true;
            }
        }

        // Cascade delete Theatre
        protected void SqlDataSource1_Deleting(object sender, SqlDataSourceCommandEventArgs e)
        {
            int theatreId = Convert.ToInt32(e.Command.Parameters["THEATRE_ID"].Value);
            try
            {
                ExecuteNonQuery(
                    "DELETE FROM \"TICKET\" WHERE \"TICKET_ID\" IN " +
                    "(SELECT \"TICKET_ID\" FROM \"SHOW_TICKET\" WHERE \"THEATRE_ID\" = :ID)",
                    Param("ID", theatreId));
                ExecuteNonQuery("DELETE FROM \"SHOW_TICKET\"   WHERE \"THEATRE_ID\" = :ID", Param("ID", theatreId));
                ExecuteNonQuery("DELETE FROM \"HALL_SHOW\"     WHERE \"THEATRE_ID\" = :ID", Param("ID", theatreId));
                ExecuteNonQuery("DELETE FROM \"MOVIE_THEATRE\" WHERE \"THEATRE_ID\" = :ID", Param("ID", theatreId));
                ExecuteNonQuery("DELETE FROM \"THEATRE_HALL\"  WHERE \"THEATRE_ID\" = :ID", Param("ID", theatreId));
            }
            catch (Exception ex)
            {
                ShowMsg("Error removing linked records: " + ex.Message, "danger");
                e.Command.CommandText = "SELECT 1 FROM DUAL";
            }
        }

        // Catch duplicate primary key — Hall
        protected void SqlDataSource2_Inserted(object sender, SqlDataSourceStatusEventArgs e)
        {
            if (e.Exception != null && e.Exception.Message.Contains("ORA-00001"))
            {
                ShowMsg("Error: Hall ID already exists. Please choose a different ID.", "danger");
                e.ExceptionHandled = true;
            }
        }

        // Cascade delete Hall
        protected void SqlDataSource2_Deleting(object sender, SqlDataSourceCommandEventArgs e)
        {
            int hallId = Convert.ToInt32(e.Command.Parameters["HALL_ID"].Value);
            try
            {
                ExecuteNonQuery(
                    "DELETE FROM \"TICKET\" WHERE \"TICKET_ID\" IN " +
                    "(SELECT \"TICKET_ID\" FROM \"SHOW_TICKET\" WHERE \"HALL_ID\" = :ID)",
                    Param("ID", hallId));
                ExecuteNonQuery("DELETE FROM \"SHOW_TICKET\"  WHERE \"HALL_ID\" = :ID", Param("ID", hallId));
                ExecuteNonQuery("DELETE FROM \"HALL_SHOW\"    WHERE \"HALL_ID\" = :ID", Param("ID", hallId));
                ExecuteNonQuery("DELETE FROM \"THEATRE_HALL\" WHERE \"HALL_ID\" = :ID", Param("ID", hallId));
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
