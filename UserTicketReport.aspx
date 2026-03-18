<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserTicketReport.aspx.cs" Inherits="KumariCinemas.UserTicketReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Ticket Report — Kumari Cinemas</title>
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
      <li class="active"><a href="UserTicketReport.aspx">&#127903; User Ticket Report</a></li>
      <li><a href="TheatreMovieReport.aspx">&#127917; Theatre Movie</a></li>
      <li><a href="OccupancyReport.aspx">&#128202; Occupancy</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#127903; User Ticket Report <small>Complex Form</small></h2>
    <p class="text-muted">Displays all tickets purchased by a selected customer in the last 6 months.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <!-- Customer list SqlDataSource -->
            <asp:SqlDataSource ID="SqlDataSourceCustomers" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "USER_ID", "USERNAME" || &apos; (ID: &apos; || "USER_ID" || &apos;)&apos; AS DISPLAY FROM "CUSTOMER" ORDER BY "USERNAME"'
                OnSelecting="SqlDataSource1_Selecting">
            </asp:SqlDataSource>

            <!-- Report results SqlDataSource — filtered by selected User_Id -->
            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT t."TICKET_ID", m."TITLE" AS MOVIE_TITLE, th."THEATRE_NAME", th."THEATRE_CITY",
                               s."SHOW_TIMES", s."SHOW_DATE", t."SEAT_NUMBER",
                               t."TICKET_PRICE", t."PAYMENT_STATUS", t."BOOKING_TIME"
                               FROM "SHOW_TICKET" st
                               JOIN "TICKET"  t  ON t."TICKET_ID"  = st."TICKET_ID"
                               JOIN "SHOW"    s  ON s."SHOW_ID"    = st."SHOW_ID"
                               JOIN "MOVIE"   m  ON m."MOVIE_ID"   = st."MOVIE_ID"
                               JOIN "THEATRE" th ON th."THEATRE_ID" = st."THEATRE_ID"
                               WHERE st."USER_ID" = :USER_ID
                               AND t."BOOKING_TIME" >= ADD_MONTHS(SYSDATE, -6)
                               ORDER BY t."BOOKING_TIME" DESC'>
                <SelectParameters>
                    <asp:ControlParameter Name="USER_ID" ControlID="ddlCustomer" PropertyName="SelectedValue" Type="Decimal" />
                </SelectParameters>
            </asp:SqlDataSource>

            <!-- Selection panel -->
            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Select Customer</strong></div>
                <div class="panel-body">
                    <div class="form-inline">
                        <label>Customer:&nbsp;</label>
                        <asp:DropDownList ID="ddlCustomer" runat="server"
                            CssClass="form-control"
                            DataSourceID="SqlDataSourceCustomers"
                            DataTextField="DISPLAY"
                            DataValueField="USER_ID"
                            AppendDataBoundItems="true"
                            AutoPostBack="true"
                            Style="min-width:300px;">
                            <asp:ListItem Value="">-- Select Customer --</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <!-- Summary stats row -->
            <asp:Panel ID="pnlStats" runat="server" Visible="false">
                <div class="row text-center" style="margin-bottom:20px;">
                    <div class="col-sm-4">
                        <div class="panel panel-danger">
                            <div class="panel-body">
                                <h3><asp:Label ID="lblTotal" runat="server" Text="0" /></h3>
                                <p>Total Tickets (last 6 months)</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="panel panel-success">
                            <div class="panel-body">
                                <h3>NPR <asp:Label ID="lblSpent" runat="server" Text="0" /></h3>
                                <p>Total Spent</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="panel panel-info">
                            <div class="panel-body">
                                <h3><asp:Label ID="lblPaid" runat="server" Text="0" /></h3>
                                <p>Paid Tickets</p>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Results GridView -->
            <div class="panel panel-default">
                <div class="panel-heading"><strong>Ticket History (Last 6 Months)</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataSourceID="SqlDataSource1"
                        EmptyDataText="No tickets found for this customer in the last 6 months."
                        OnDataBound="GridView1_DataBound">
                        <Columns>
                            <asp:BoundField DataField="TICKET_ID"      HeaderText="Ticket #"    />
                            <asp:BoundField DataField="MOVIE_TITLE"    HeaderText="Movie"       />
                            <asp:BoundField DataField="THEATRE_NAME"   HeaderText="Theatre"     />
                            <asp:BoundField DataField="THEATRE_CITY"   HeaderText="City"        />
                            <asp:BoundField DataField="SHOW_TIMES"     HeaderText="Show Time"   />
                            <asp:BoundField DataField="SHOW_DATE"      HeaderText="Show Date"   DataFormatString="{0:dd-MMM-yyyy}" />
                            <asp:BoundField DataField="SEAT_NUMBER"    HeaderText="Seat"        />
                            <asp:BoundField DataField="TICKET_PRICE"   HeaderText="Price (NPR)" DataFormatString="{0:N0}" />
                            <asp:BoundField DataField="PAYMENT_STATUS" HeaderText="Status"      />
                            <asp:BoundField DataField="BOOKING_TIME"   HeaderText="Booked On"   DataFormatString="{0:dd-MMM-yy}" />
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
