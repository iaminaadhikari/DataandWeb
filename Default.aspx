<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="KumariCinemas.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard — Kumari Cinemas</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
</head>
<body>
<nav class="navbar navbar-inverse">
  <div class="container-fluid">
    <div class="navbar-header">
      <a class="navbar-brand" href="Default.aspx">&#127916; Kumari Cinemas</a>
    </div>
    <ul class="nav navbar-nav">
      <li class="active"><a href="Default.aspx">Dashboard</a></li>
      <li><a href="User.aspx">&#128100; User</a></li>
      <li><a href="Theatre.aspx">&#127963; Theatre</a></li>
      <li><a href="Show.aspx">&#9200; Show</a></li>
      <li><a href="Movie.aspx">&#127916; Movie</a></li>
      <li><a href="Ticket.aspx">&#127915; Ticket</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; Reports</a></li>
    </ul>
    <p class="navbar-text navbar-right">CC6012 &mdash; Ina Adhikari (23049014)</p>
  </div>
</nav>

<div class="container" style="margin-top:20px;">

    <div class="jumbotron" style="background:#1a1a2e; color:#fff;">
        <h1>Welcome to <span style="color:#e94560;">Kumari Cinemas</span></h1>
        <p class="lead">Centralised Cinema Management System &mdash; Nepal</p>
        <p><asp:Label ID="lblDate" runat="server" CssClass="label label-default" /></p>
    </div>

    <form id="form1" runat="server">

        <!-- Live Stats -->
        <asp:SqlDataSource ID="SqlDataSource1" runat="server"
            ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
            ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
            SelectCommand="SELECT 'stats' AS ROW_TYPE,
                           (SELECT COUNT(*) FROM &quot;CUSTOMER&quot;) AS CUSTOMERS,
                           (SELECT COUNT(*) FROM &quot;MOVIE&quot;) AS MOVIES,
                           (SELECT COUNT(*) FROM &quot;THEATRE&quot;) AS THEATRES,
                           (SELECT COUNT(*) FROM &quot;TICKET&quot; WHERE &quot;PAYMENT_STATUS&quot;='Paid') AS TICKETS
                           FROM DUAL" />

        <asp:GridView ID="GridView1" runat="server"
            DataSourceID="SqlDataSource1"
            AutoGenerateColumns="False"
            CssClass="table table-bordered text-center"
            ShowHeader="True"
            GridLines="Both">
            <Columns>
                <asp:BoundField DataField="CUSTOMERS" HeaderText="Registered Customers" />
                <asp:BoundField DataField="MOVIES"    HeaderText="Active Movies"        />
                <asp:BoundField DataField="THEATRES"  HeaderText="Theatres Nationwide"  />
                <asp:BoundField DataField="TICKETS"   HeaderText="Tickets Sold (Paid)"  />
            </Columns>
        </asp:GridView>


        <asp:SqlDataSource ID="SqlDataSourceTicketStatus" runat="server"
            ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
            ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
            SelectCommand="SELECT
                           NVL(SUM(CASE WHEN &quot;PAYMENT_STATUS&quot;='Paid' THEN 1 ELSE 0 END),0) AS PAID,
                           NVL(SUM(CASE WHEN &quot;PAYMENT_STATUS&quot;='Unpaid' THEN 1 ELSE 0 END),0) AS UNPAID,
                           NVL(SUM(CASE WHEN &quot;PAYMENT_STATUS&quot;='Discounted' THEN 1 ELSE 0 END),0) AS DISCOUNTED
                           FROM &quot;TICKET&quot;" />

        <asp:GridView ID="GridViewTicketStatus" runat="server"
            DataSourceID="SqlDataSourceTicketStatus"
            AutoGenerateColumns="True"
            Visible="false" />

        <asp:Label ID="lblPaid"       runat="server" style="display:none;" />
        <asp:Label ID="lblUnpaid"     runat="server" style="display:none;" />
        <asp:Label ID="lblDiscounted" runat="server" style="display:none;" />

        <div class="row" style="margin-top:20px; margin-bottom:10px;">
            <div class="col-sm-6 col-sm-offset-3">
                <div class="panel panel-default">
                    <div class="panel-heading"><strong>&#127915; Ticket Status Overview</strong></div>
                    <div class="panel-body" style="text-align:center;">
                        <canvas id="ticketPieChart" width="300" height="300"
                                style="max-width:300px; display:inline-block;"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <script>
            (function () {
                function getVal(id) {
                    var el = document.getElementById(id);
                    return el ? parseInt(el.innerText || el.textContent || '0', 10) : 0;
                }
                function tryDraw() {
                    if (typeof Chart === 'undefined') {
                        setTimeout(tryDraw, 100);
                        return;
                    }
                    var paid = getVal('<%= lblPaid.ClientID %>');
                    var unpaid = getVal('<%= lblUnpaid.ClientID %>');
                    var discounted = getVal('<%= lblDiscounted.ClientID %>');
                    var ctx = document.getElementById('ticketPieChart');
                    if (!ctx) return;
                    new Chart(ctx.getContext('2d'), {
                        type: 'pie',
                        data: {
                            labels: ['Paid', 'Unpaid', 'Discounted'],
                            datasets: [{
                                data: [paid, unpaid, discounted],
                                backgroundColor: ['#5cb85c', '#d9534f', '#f0ad4e'],
                                borderColor: ['#fff', '#fff', '#fff'],
                                borderWidth: 2
                            }]
                        },
                        options: {
                            responsive: false,
                            plugins: {
                                legend: { position: 'bottom' },
                                title: { display: false }
                            }
                        }
                    });
                }
                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', tryDraw);
                } else {
                    tryDraw();
                }
            })();
        </script>
    </form>


    <h3>Quick Access</h3>
    <div class="row">
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#128100; User Details</strong> <span class="label label-default pull-right">Basic</span></div>
                <div class="panel-body">Manage customer registrations.</div>
                <div class="panel-footer"><a href="User.aspx" class="btn btn-danger btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#127963; TheatreCityHall Details</strong> <span class="label label-default pull-right">Basic</span></div>
                <div class="panel-body">Manage theatres and hall capacities.</div>
                <div class="panel-footer"><a href="Theatre.aspx" class="btn btn-danger btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#9200; ShowTimes Details</strong> <span class="label label-default pull-right">Basic</span></div>
                <div class="panel-body">Configure Morning, Day and Evening shows.</div>
                <div class="panel-footer"><a href="Show.aspx" class="btn btn-danger btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#127916; Movie Details</strong> <span class="label label-default pull-right">Basic</span></div>
                <div class="panel-body">Manage movies, language, genre and release dates.</div>
                <div class="panel-footer"><a href="Movie.aspx" class="btn btn-danger btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#127915; Ticket Details</strong> <span class="label label-default pull-right">Basic</span></div>
                <div class="panel-body">Manage ticket bookings and payment status.</div>
                <div class="panel-footer"><a href="Ticket.aspx" class="btn btn-danger btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#127903; User Ticket Report</strong> <span class="label label-primary pull-right">Complex</span></div>
                <div class="panel-body">Tickets purchased by any user in the last 6 months.</div>
                <div class="panel-footer"><a href="UserTicketReport.aspx" class="btn btn-primary btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#127917; TheatreCityHall Movie</strong> <span class="label label-primary pull-right">Complex</span></div>
                <div class="panel-body">For any theatre, view all movies showing with showtimes.</div>
                <div class="panel-footer"><a href="TheatreMovieReport.aspx" class="btn btn-primary btn-sm">Open &rarr;</a></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="panel panel-default">
                <div class="panel-heading"><strong>&#128202; Occupancy Performer</strong> <span class="label label-primary pull-right">Complex</span></div>
                <div class="panel-body">Top 3 theatres by occupancy % for any movie (paid only).</div>
                <div class="panel-footer"><a href="OccupancyReport.aspx" class="btn btn-primary btn-sm">Open &rarr;</a></div>
            </div>
        </div>
    </div>

</div>

<footer class="text-center text-muted" style="padding:15px; margin-top:20px; border-top:1px solid #eee;">
    &copy; 2026 Kumari Cinemas &mdash; Ina Adhikari (23049014)
</footer>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</body>
</html>
