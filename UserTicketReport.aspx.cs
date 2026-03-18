using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace KumariCinemas
{
    public partial class UserTicketReport : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void SqlDataSource1_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
        {

        }

        // Calculate summary stats after GridView data is bound
        protected void GridView1_DataBound(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCustomer.SelectedValue))
            {
                pnlStats.Visible = false;
                return;
            }

            int     total = 0;
            decimal spent = 0;
            int     paid  = 0;

            foreach (GridViewRow row in GridView1.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    total++;
                    string priceText = row.Cells[7].Text.Replace(",", "");
                    if (decimal.TryParse(priceText, out decimal p)) spent += p;
                    if (row.Cells[8].Text == "Paid" || row.Cells[8].Text == "Discounted") paid++;
                }
            }

            lblTotal.Text    = total.ToString();
            lblSpent.Text    = spent.ToString("N0");
            lblPaid.Text     = paid.ToString();
            pnlStats.Visible = (total > 0);
        }
    }
}
