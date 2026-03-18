<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TheatreMovieReport.aspx.cs" Inherits="KumariCinemas.TheatreMovieReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>TheatreCityHall Movie Report — Kumari Cinemas</title>
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
      <li class="active"><a href="TheatreMovieReport.aspx">&#127917; Theatre Movie</a></li>
      <li><a href="OccupancyReport.aspx">&#128202; Occupancy</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#127917; TheatreCityHall Movie Report <small>Complex Form</small></h2>
    <p class="text-muted">For any selected theatre, view all movies currently showing with showtimes and hall capacities.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <!-- Theatre list SqlDataSource -->
            <asp:SqlDataSource ID="SqlDataSourceTheatres" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "THEATRE_ID", "THEATRE_CITY" || &apos; - &apos; || "THEATRE_NAME" AS DISPLAY FROM "THEATRE" ORDER BY "THEATRE_CITY", "THEATRE_NAME"'
                OnSelecting="SqlDataSource1_Selecting">
            </asp:SqlDataSource>

            <!-- Report results SqlDataSource — filtered by selected Theatre_Id -->
            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT DISTINCT m."TITLE" AS MOVIE_TITLE, m."LANGUAGE", m."GENRE", m."DURATION",
                               h."HALL_CAPACITY", s."SHOW_TIMES", s."SHOW_DATE"
                               FROM "HALL_SHOW" hs
                               JOIN "SHOW"    s  ON s."SHOW_ID"    = hs."SHOW_ID"
                               JOIN "MOVIE"   m  ON m."MOVIE_ID"   = hs."MOVIE_ID"
                               JOIN "HALL"    h  ON h."HALL_ID"    = hs."HALL_ID"
                               JOIN "THEATRE" t  ON t."THEATRE_ID" = hs."THEATRE_ID"
                               WHERE hs."THEATRE_ID" = :THEATRE_ID
                               ORDER BY s."SHOW_DATE", s."SHOW_TIMES", m."TITLE"'>
                <SelectParameters>
                    <asp:ControlParameter Name="THEATRE_ID" ControlID="ddlTheatre" PropertyName="SelectedValue" Type="Decimal" />
                </SelectParameters>
            </asp:SqlDataSource>

            <!-- Selection panel -->
            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Select Theatre</strong></div>
                <div class="panel-body">
                    <div class="form-inline">
                        <label>Theatre:&nbsp;</label>
                        <asp:DropDownList ID="ddlTheatre" runat="server"
                            CssClass="form-control"
                            DataSourceID="SqlDataSourceTheatres"
                            DataTextField="DISPLAY"
                            DataValueField="THEATRE_ID"
                            AppendDataBoundItems="true"
                            AutoPostBack="true"
                            Style="min-width:320px;">
                            <asp:ListItem Value="">-- Select Theatre --</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <!-- Results GridView -->
            <div class="panel panel-default">
                <div class="panel-heading"><strong>Movies &amp; Showtimes</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataSourceID="SqlDataSource1"
                        EmptyDataText="No movies or shows found for this theatre.">
                        <Columns>
                            <asp:BoundField DataField="MOVIE_TITLE"   HeaderText="Movie Title"    />
                            <asp:BoundField DataField="LANGUAGE"      HeaderText="Language"       />
                            <asp:BoundField DataField="GENRE"         HeaderText="Genre"          />
                            <asp:BoundField DataField="DURATION"      HeaderText="Duration (min)" />
                            <asp:BoundField DataField="HALL_CAPACITY" HeaderText="Hall Capacity"  />
                            <asp:BoundField DataField="SHOW_TIMES"    HeaderText="Show Time"      />
                            <asp:BoundField DataField="SHOW_DATE"     HeaderText="Show Date"      DataFormatString="{0:dd-MMM-yyyy}" />
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
