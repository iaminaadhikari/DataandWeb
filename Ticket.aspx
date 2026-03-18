<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Ticket.aspx.cs" Inherits="KumariCinemas.Ticket" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Ticket Details &mdash; Kumari Cinemas</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" />
    <style>
        .form-group { margin-bottom:14px; }
    </style>
</head>
<body>
<nav class="navbar navbar-inverse">
  <div class="container-fluid">
    <div class="navbar-header">
      <a class="navbar-brand" href="Default.aspx">&#127916; Kumari Cinemas</a>
    </div>
    <ul class="nav navbar-nav">
      <li><a href="Default.aspx">Dashboard</a></li>
      <li><a href="User.aspx">&#128100; User</a></li>
      <li><a href="Theatre.aspx">&#127963; Theatre</a></li>
      <li><a href="Show.aspx">&#9200; Show</a></li>
      <li><a href="Movie.aspx">&#127916; Movie</a></li>
      <li class="active"><a href="Ticket.aspx">&#127915; Ticket</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; Reports</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#127915; Ticket Details <small>Basic Form</small></h2>
    <p class="text-muted">Manage ticket bookings and payment status.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <asp:Label ID="lblMsg" runat="server" Visible="false" />

            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT t."TICKET_ID", c."USERNAME", m."TITLE" AS MOVIE_TITLE,
                               th."THEATRE_NAME", s."SHOW_TIMES", s."SHOW_DATE",
                               t."TICKET_PRICE", t."BOOKING_TIME", t."PURCHASE_TIME",
                               t."PAYMENT_STATUS", t."SEAT_NUMBER"
                               FROM "TICKET" t
                               LEFT JOIN "SHOW_TICKET" st ON st."TICKET_ID"  = t."TICKET_ID"
                               LEFT JOIN "CUSTOMER"    c  ON c."USER_ID"     = st."USER_ID"
                               LEFT JOIN "MOVIE"       m  ON m."MOVIE_ID"    = st."MOVIE_ID"
                               LEFT JOIN "SHOW"        s  ON s."SHOW_ID"     = st."SHOW_ID"
                               LEFT JOIN "THEATRE"     th ON th."THEATRE_ID" = st."THEATRE_ID"
                               ORDER BY t."TICKET_ID"'
                UpdateCommand='UPDATE "TICKET" SET "TICKET_PRICE"=:TICKET_PRICE, "BOOKING_TIME"=TO_DATE(:BOOKING_TIME,&apos;YYYY-MM-DD&apos;), "PURCHASE_TIME"=TO_DATE(:PURCHASE_TIME,&apos;YYYY-MM-DD&apos;), "PAYMENT_STATUS"=:PAYMENT_STATUS, "SEAT_NUMBER"=:SEAT_NUMBER WHERE "TICKET_ID"=:TICKET_ID'
                DeleteCommand='DELETE FROM "TICKET" WHERE "TICKET_ID"=:TICKET_ID'
                OnDeleting="SqlDataSource1_Deleting"
                OnUpdating="SqlDataSource1_Updating"
                OnSelecting="SqlDataSource1_Selecting">
                <UpdateParameters>
                    <asp:Parameter Name="TICKET_PRICE"   Type="Decimal" />
                    <asp:Parameter Name="BOOKING_TIME"   Type="String"  />
                    <asp:Parameter Name="PURCHASE_TIME"  Type="String"  />
                    <asp:Parameter Name="PAYMENT_STATUS" Type="String"  />
                    <asp:Parameter Name="SEAT_NUMBER"    Type="String"  />
                    <asp:Parameter Name="TICKET_ID"      Type="Decimal" />
                </UpdateParameters>
                <DeleteParameters>
                    <asp:Parameter Name="TICKET_ID" Type="Decimal" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Ticket List</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataKeyNames="TICKET_ID"
                        DataSourceID="SqlDataSource1"
                        OnRowEditing="GridView1_RowEditing"
                        OnRowCancelingEdit="GridView1_RowCancelingEdit">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />
                            <asp:BoundField DataField="TICKET_ID"     HeaderText="ID"           ReadOnly="True" SortExpression="TICKET_ID"    />
                            <asp:BoundField DataField="USERNAME"      HeaderText="Customer"     ReadOnly="True" />
                            <asp:BoundField DataField="MOVIE_TITLE"   HeaderText="Movie"        ReadOnly="True" />
                            <asp:BoundField DataField="THEATRE_NAME"  HeaderText="Theatre"      ReadOnly="True" />
                            <asp:BoundField DataField="SHOW_TIMES"    HeaderText="Show"         ReadOnly="True" />
                            <asp:BoundField DataField="SHOW_DATE"     HeaderText="Show Date"    ReadOnly="True" DataFormatString="{0:dd-MMM-yy}" />
                            <asp:BoundField DataField="TICKET_PRICE"  HeaderText="Price (NPR)"  SortExpression="TICKET_PRICE"  DataFormatString="{0:N0}" />
                            <asp:BoundField DataField="BOOKING_TIME"  HeaderText="Booked"       SortExpression="BOOKING_TIME"  DataFormatString="{0:dd-MMM-yy}" />
                            <asp:BoundField DataField="PURCHASE_TIME" HeaderText="Purchased"    SortExpression="PURCHASE_TIME" DataFormatString="{0:dd-MMM-yy}" NullDisplayText="N/A (Unpaid)" />
                            <asp:TemplateField HeaderText="Status" SortExpression="PAYMENT_STATUS">
                                <ItemTemplate>
                                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("PAYMENT_STATUS") %>' />
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:DropDownList ID="ddlStatus" runat="server"
                                        SelectedValue='<%# Bind("PAYMENT_STATUS") %>'
                                        CssClass="form-control input-sm">
                                        <asp:ListItem>Paid</asp:ListItem>
                                        <asp:ListItem>Unpaid</asp:ListItem>
                                        <asp:ListItem>Discounted</asp:ListItem>
                                    </asp:DropDownList>
                                </EditItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="SEAT_NUMBER" HeaderText="Seat" SortExpression="SEAT_NUMBER" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="panel panel-success">
                <div class="panel-heading"><strong>Insert New Ticket</strong></div>
                <div class="panel-body">

                    <asp:Button ID="btnShowForm" runat="server"
                        Text="+ New Ticket"
                        CssClass="btn btn-success btn-sm"
                        OnClick="btnShowForm_Click"
                        CausesValidation="false" />

                    <asp:FormView ID="FormView1" runat="server"
                        DataKeyNames="TICKET_ID"
                        OnItemInserting="FormView1_ItemInserting"
                        OnModeChanged="FormView1_ModeChanged">

                        <ItemTemplate></ItemTemplate>

                        <InsertItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Ticket ID <span class="text-danger">*</span></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="TICKET_IDTextBox" runat="server"
                                            Text='<%# Bind("TICKET_ID") %>'
                                            CssClass="form-control" placeholder="e.g. 21" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="TICKET_IDTextBox"
                                            ValidationGroup="InsertTicket" Display="None"
                                            ErrorMessage="Ticket ID is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="TICKET_IDTextBox"
                                            ValidationGroup="InsertTicket"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Ticket ID must be a whole number (e.g. 21)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Customer <span class="text-danger">*</span></label>
                                    <div class="col-sm-5">
                                        <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="ddlCustomer"
                                            ValidationGroup="InsertTicket"
                                            InitialValue="" Display="None"
                                            ErrorMessage="Customer is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Show <span class="text-danger">*</span>
                                        <small class="text-muted d-block">Movie, Theatre &amp; Hall are linked automatically</small>
                                    </label>
                                    <div class="col-sm-6">
                                        <asp:DropDownList ID="ddlShow" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="ddlShow"
                                            ValidationGroup="InsertTicket"
                                            InitialValue="" Display="None"
                                            ErrorMessage="Show is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Price NPR <span class="text-danger">*</span> <small>(50-5000)</small></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="TICKET_PRICETextBox" runat="server"
                                            Text='<%# Bind("TICKET_PRICE") %>'
                                            CssClass="form-control" placeholder="e.g. 350" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="TICKET_PRICETextBox"
                                            ValidationGroup="InsertTicket" Display="None"
                                            ErrorMessage="Ticket Price is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="TICKET_PRICETextBox"
                                            ValidationGroup="InsertTicket"
                                            Operator="DataTypeCheck" Type="Double"
                                            Display="None"
                                            ErrorMessage="Ticket Price must be a number (e.g. 350)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Booking Date <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:TextBox ID="BOOKING_TIMETextBox" runat="server"
                                            Text='<%# Bind("BOOKING_TIME") %>'
                                            CssClass="form-control" TextMode="Date" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="BOOKING_TIMETextBox"
                                            ValidationGroup="InsertTicket" Display="None"
                                            ErrorMessage="Booking Date is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Payment Status <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:DropDownList ID="PAYMENT_STATUSDropDown" runat="server"
                                            SelectedValue='<%# Bind("PAYMENT_STATUS") %>'
                                            CssClass="form-control">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem>Paid</asp:ListItem>
                                            <asp:ListItem>Unpaid</asp:ListItem>
                                            <asp:ListItem>Discounted</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="PAYMENT_STATUSDropDown"
                                            ValidationGroup="InsertTicket"
                                            InitialValue="" Display="None"
                                            ErrorMessage="Payment Status is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Purchase Date <small class="text-muted">(Paid or Discounted only)</small></label>
                                    <div class="col-sm-4">
                                        <asp:TextBox ID="PURCHASE_TIMETextBox" runat="server"
                                            Text='<%# Bind("PURCHASE_TIME") %>'
                                            CssClass="form-control" TextMode="Date" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Seat <span class="text-danger">*</span> <small>(e.g. A15)</small></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="SEAT_NUMBERTextBox" runat="server"
                                            Text='<%# Bind("SEAT_NUMBER") %>'
                                            CssClass="form-control" placeholder="A15" MaxLength="5" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="SEAT_NUMBERTextBox"
                                            ValidationGroup="InsertTicket" Display="None"
                                            ErrorMessage="Seat Number is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:ValidationSummary ID="vsTicket" runat="server"
                                            ShowMessageBox="false" ShowSummary="true"
                                            DisplayMode="BulletList"
                                            ValidationGroup="InsertTicket"
                                            CssClass="alert alert-danger"
                                            HeaderText="Please fix the following:" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:LinkButton ID="InsertButton" runat="server"
                                            CausesValidation="True" CommandName="Insert"
                                            ValidationGroup="InsertTicket"
                                            Text="Insert Ticket" CssClass="btn btn-primary btn-sm" />
                                        &nbsp;
                                        <asp:LinkButton ID="InsertCancelButton" runat="server"
                                            CausesValidation="False" CommandName="Cancel"
                                            Text="Cancel" CssClass="btn btn-default btn-sm" />
                                    </div>
                                </div>

                            </div>
                        </InsertItemTemplate>

                    </asp:FormView>
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
