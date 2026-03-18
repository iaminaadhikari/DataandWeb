using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace KumariCinemas
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblDate.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

            // Populate hidden labels used by the pie chart JavaScript
            DataView dv = (DataView)SqlDataSourceTicketStatus.Select(DataSourceSelectArguments.Empty);
            if (dv != null && dv.Count > 0)
            {
                DataRow row = dv[0].Row;
                lblPaid.Text = row["PAID"].ToString();
                lblUnpaid.Text = row["UNPAID"].ToString();
                lblDiscounted.Text = row["DISCOUNTED"].ToString();
            }
            else
            {
                lblPaid.Text = lblUnpaid.Text = lblDiscounted.Text = "0";
            }
        }
    }
}
