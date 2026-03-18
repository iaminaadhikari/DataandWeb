<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OccupancyReport.aspx.cs" Inherits="KumariCinemas.OccupancyReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Occupancy Performer Report — Kumari Cinemas</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" />
</head>
<body>
<nav class="navbar navbar-inverse">
  <div class="container-fluid">
    <div class="navbar-header">
      <a class="navbar-brand" href="Default.aspx">&#127916; Kumari Cinemas</a>
    </div>
    <ul class="nav navbar-nav">
      <li><a href="Default.aspx">Dashboard</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; User Ticket</a></li>
      <li><a href="TheatreMovieReport.aspx">&#127917; Theatre Movie</a></li>
      <li class="active"><a href="OccupancyReport.aspx">&#128202; Occupancy</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#128202; Movie Theatre Occupancy Performer <small>Complex Form</small></h2>
    <p class="text-muted">Displays the top 3 theatres with the highest seat occupancy percentage for a selected movie. Only Paid and Discounted tickets are counted as occupied seats.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <!-- Movie list SqlDataSource -->
            <asp:SqlDataSource ID="SqlDataSourceMovies" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "MOVIE_ID", "TITLE" || &apos; (&apos; || "LANGUAGE" || &apos;)&apos; AS DISPLAY FROM "MOVIE" ORDER BY "TITLE"'
                OnSelecting="SqlDataSource1_Selecting">
            </asp:SqlDataSource>


            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT ROWNUM AS RANK, THEATRE_NAME, THEATRE_CITY, HALL_CAPACITY, PAID_TICKETS,
                               ROUND((PAID_TICKETS / HALL_CAPACITY) * 100, 2) AS OCCUPANCY_PCT
                               FROM (
                                   SELECT th."THEATRE_NAME"        AS THEATRE_NAME,
                                          th."THEATRE_CITY"        AS THEATRE_CITY,
                                          MAX(h."HALL_CAPACITY")   AS HALL_CAPACITY,
                                          COUNT(t."TICKET_ID")     AS PAID_TICKETS
                                   FROM "HALL_SHOW" hs
                                   JOIN "THEATRE"     th ON th."THEATRE_ID" = hs."THEATRE_ID"
                                   JOIN "HALL"         h ON h."HALL_ID"     = hs."HALL_ID"
                                   JOIN "SHOW_TICKET" st ON st."SHOW_ID"    = hs."SHOW_ID"
                                                        AND st."MOVIE_ID"   = hs."MOVIE_ID"
                                   JOIN "TICKET"       t ON t."TICKET_ID"   = st."TICKET_ID"
                                                        AND t."PAYMENT_STATUS" IN (&apos;Paid&apos;,&apos;Discounted&apos;)
                                   WHERE hs."MOVIE_ID" = :MOVIE_ID
                                   GROUP BY th."THEATRE_NAME", th."THEATRE_CITY"
                                   ORDER BY PAID_TICKETS DESC, HALL_CAPACITY DESC
                               )
                               WHERE ROWNUM &lt;= 3'>
                <SelectParameters>
                    <asp:ControlParameter Name="MOVIE_ID" ControlID="ddlMovie" PropertyName="SelectedValue" Type="Decimal" />
                </SelectParameters>
            </asp:SqlDataSource>

            <!-- Movie selection panel -->
            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Movie Selection</strong></div>
                <div class="panel-body">
                    <div class="form-inline">
                        <label>Movie:&nbsp;</label>
                        <asp:DropDownList ID="ddlMovie" runat="server"
                            CssClass="form-control"
                            DataSourceID="SqlDataSourceMovies"
                            DataTextField="DISPLAY"
                            DataValueField="MOVIE_ID"
                            AppendDataBoundItems="true"
                            AutoPostBack="true"
                            Style="min-width:320px;">
                            <asp:ListItem Value="">-- Select Movie --</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <!-- Results GridView -->
            <div class="panel panel-default">
                <div class="panel-heading"><strong>Top 3 Theatres by Occupancy % (Paid Tickets Only)</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataSourceID="SqlDataSource1"
                        EmptyDataText="No paid ticket data found for this movie.">
                        <Columns>
                            <asp:BoundField DataField="RANK"          HeaderText="Rank"          />
                            <asp:BoundField DataField="THEATRE_NAME"  HeaderText="Theatre"       />
                            <asp:BoundField DataField="THEATRE_CITY"  HeaderText="City"          />
                            <asp:BoundField DataField="HALL_CAPACITY" HeaderText="Hall Capacity" />
                            <asp:BoundField DataField="PAID_TICKETS"  HeaderText="Paid Tickets"  />
                            <asp:BoundField DataField="OCCUPANCY_PCT" HeaderText="Occupancy %"   DataFormatString="{0:F2}%" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </form>
</div>

<footer class="text-center text-muted" style="padding:15px; margin-top:20px; border-top:1px solid #eee;">
    &copy; 2026 Kumari Cinemas &mdash; Ina Adhikari (23049014)
</footer>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</body>
</html>
