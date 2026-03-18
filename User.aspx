<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="User.aspx.cs" Inherits="KumariCinemas.User" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Details &mdash; Kumari Cinemas</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" />
    <style>
        .field-error { color:#a94442; font-size:12px; margin-top:3px; }
        .form-group  { margin-bottom:14px; }
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
      <li class="active"><a href="User.aspx">&#128100; User</a></li>
      <li><a href="Theatre.aspx">&#127963; Theatre</a></li>
      <li><a href="Show.aspx">&#9200; Show</a></li>
      <li><a href="Movie.aspx">&#127916; Movie</a></li>
      <li><a href="Ticket.aspx">&#127915; Ticket</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; Reports</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#128100; User Details <small>Basic Form</small></h2>
    <p class="text-muted">Add, view, update and delete customer records.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "USER_ID", "USERNAME", "ADDRESS" FROM "CUSTOMER" ORDER BY "USER_ID"'
                InsertCommand='INSERT INTO "CUSTOMER" ("USER_ID", "USERNAME", "ADDRESS") VALUES (:USER_ID, :USERNAME, :ADDRESS)'
                UpdateCommand='UPDATE "CUSTOMER" SET "USERNAME" = :USERNAME, "ADDRESS" = :ADDRESS WHERE "USER_ID" = :USER_ID'
                DeleteCommand='DELETE FROM "CUSTOMER" WHERE "USER_ID" = :USER_ID'
                OnSelecting="SqlDataSource1_Selecting"
                OnInserted="SqlDataSource1_Inserted"
                OnDeleting="SqlDataSource1_Deleting">
                <InsertParameters>
                    <asp:Parameter Name="USER_ID"  Type="Decimal" />
                    <asp:Parameter Name="USERNAME" Type="String"  />
                    <asp:Parameter Name="ADDRESS"  Type="String"  />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="USERNAME" Type="String"  />
                    <asp:Parameter Name="ADDRESS"  Type="String"  />
                    <asp:Parameter Name="USER_ID"  Type="Decimal" />
                </UpdateParameters>
                <DeleteParameters>
                    <asp:Parameter Name="USER_ID"  Type="Decimal" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <asp:Label ID="lblMsg" runat="server" Visible="false" />

            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Customer List</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataKeyNames="USER_ID"
                        DataSourceID="SqlDataSource1">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />
                            <asp:BoundField DataField="USER_ID"  HeaderText="User ID"  ReadOnly="True" SortExpression="USER_ID"  />
                            <asp:BoundField DataField="USERNAME" HeaderText="Username"            SortExpression="USERNAME" />
                            <asp:BoundField DataField="ADDRESS"  HeaderText="Address"             SortExpression="ADDRESS"  />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="panel panel-success">
                <div class="panel-heading"><strong>Insert New Customer</strong></div>
                <div class="panel-body">

                    <asp:ValidationSummary ID="vsSummary" runat="server"
                        ShowMessageBox="false" ShowSummary="false"
                        ValidationGroup="InsertUser" />

                    <asp:FormView ID="FormView1" runat="server"
                        DataKeyNames="USER_ID"
                        DataSourceID="SqlDataSource1">

                        <ItemTemplate>
                            <asp:LinkButton ID="NewButton" runat="server"
                                CausesValidation="False" CommandName="New"
                                Text="+ New Customer" CssClass="btn btn-success btn-sm" />
                        </ItemTemplate>

                        <InsertItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">User ID <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:TextBox ID="USER_IDTextBox" runat="server"
                                            Text='<%# Bind("USER_ID") %>'
                                            CssClass="form-control"
                                            placeholder="Enter a number e.g. 19" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="USER_IDTextBox"
                                            ValidationGroup="InsertUser"
                                            Display="None"
                                            ErrorMessage="User ID is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="USER_IDTextBox"
                                            ValidationGroup="InsertUser"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="User ID must be a whole number (e.g. 19)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Username <span class="text-danger">*</span></label>
                                    <div class="col-sm-5">
                                        <asp:TextBox ID="USERNAMETextBox" runat="server"
                                            Text='<%# Bind("USERNAME") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. Ram Shrestha" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="USERNAMETextBox"
                                            ValidationGroup="InsertUser"
                                            Display="None"
                                            ErrorMessage="Username is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Address</label>
                                    <div class="col-sm-6">
                                        <asp:TextBox ID="ADDRESSTextBox" runat="server"
                                            Text='<%# Bind("ADDRESS") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. Thamel, Kathmandu" />
                                    </div>
                                </div>

                                <div class="form-group" id="divValErrors" runat="server">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:ValidationSummary ID="vsInline" runat="server"
                                            ShowMessageBox="false"
                                            ShowSummary="true"
                                            DisplayMode="BulletList"
                                            ValidationGroup="InsertUser"
                                            CssClass="alert alert-danger"
                                            HeaderText="Please fix the following:" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:LinkButton ID="InsertButton" runat="server"
                                            CausesValidation="True"
                                            CommandName="Insert"
                                            ValidationGroup="InsertUser"
                                            Text="Insert"
                                            CssClass="btn btn-primary btn-sm" />
                                        &nbsp;
                                        <asp:LinkButton ID="InsertCancelButton" runat="server"
                                            CausesValidation="False"
                                            CommandName="Cancel"
                                            Text="Cancel"
                                            CssClass="btn btn-default btn-sm" />
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
