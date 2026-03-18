<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Theatre.aspx.cs" Inherits="KumariCinemas.Theatre" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>TheatreCityHall Details &mdash; Kumari Cinemas</title>
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
      <li class="active"><a href="Theatre.aspx">&#127963; Theatre</a></li>
      <li><a href="Show.aspx">&#9200; Show</a></li>
      <li><a href="Movie.aspx">&#127916; Movie</a></li>
      <li><a href="Ticket.aspx">&#127915; Ticket</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; Reports</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#127963; TheatreCityHall Details <small>Basic Form</small></h2>
    <p class="text-muted">Manage theatre locations. Hall management is on this page too &mdash; scroll down.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "THEATRE_ID", "THEATRE_NAME", "THEATRE_CITY" FROM "THEATRE" ORDER BY "THEATRE_ID"'
                InsertCommand='INSERT INTO "THEATRE" ("THEATRE_ID", "THEATRE_NAME", "THEATRE_CITY") VALUES (:THEATRE_ID, :THEATRE_NAME, :THEATRE_CITY)'
                UpdateCommand='UPDATE "THEATRE" SET "THEATRE_NAME"=:THEATRE_NAME, "THEATRE_CITY"=:THEATRE_CITY WHERE "THEATRE_ID"=:THEATRE_ID'
                DeleteCommand='DELETE FROM "THEATRE" WHERE "THEATRE_ID"=:THEATRE_ID'
                OnSelecting="SqlDataSource1_Selecting"
                OnInserted="SqlDataSource1_Inserted"
                OnDeleting="SqlDataSource1_Deleting">
                <InsertParameters>
                    <asp:Parameter Name="THEATRE_ID"   Type="Decimal" />
                    <asp:Parameter Name="THEATRE_NAME" Type="String"  />
                    <asp:Parameter Name="THEATRE_CITY" Type="String"  />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="THEATRE_NAME" Type="String"  />
                    <asp:Parameter Name="THEATRE_CITY" Type="String"  />
                    <asp:Parameter Name="THEATRE_ID"   Type="Decimal" />
                </UpdateParameters>
                <DeleteParameters>
                    <asp:Parameter Name="THEATRE_ID"   Type="Decimal" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource2" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "HALL_ID", "HALL_CAPACITY" FROM "HALL" ORDER BY "HALL_ID"'
                InsertCommand='INSERT INTO "HALL" ("HALL_ID", "HALL_CAPACITY") VALUES (:HALL_ID, :HALL_CAPACITY)'
                UpdateCommand='UPDATE "HALL" SET "HALL_CAPACITY"=:HALL_CAPACITY WHERE "HALL_ID"=:HALL_ID'
                DeleteCommand='DELETE FROM "HALL" WHERE "HALL_ID"=:HALL_ID'
                OnInserted="SqlDataSource2_Inserted"
                OnDeleting="SqlDataSource2_Deleting">
                <InsertParameters>
                    <asp:Parameter Name="HALL_ID"       Type="Decimal" />
                    <asp:Parameter Name="HALL_CAPACITY" Type="Decimal" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="HALL_CAPACITY" Type="Decimal" />
                    <asp:Parameter Name="HALL_ID"       Type="Decimal" />
                </UpdateParameters>
                <DeleteParameters>
                    <asp:Parameter Name="HALL_ID"       Type="Decimal" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <asp:Label ID="lblMsg" runat="server" Visible="false" />

            <div class="panel panel-primary">
                <div class="panel-heading"><strong>&#127963; Theatre List</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataKeyNames="THEATRE_ID"
                        DataSourceID="SqlDataSource1">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />
                            <asp:BoundField DataField="THEATRE_ID"   HeaderText="Theatre ID"   ReadOnly="True" SortExpression="THEATRE_ID"   />
                            <asp:BoundField DataField="THEATRE_NAME" HeaderText="Theatre Name"               SortExpression="THEATRE_NAME" />
                            <asp:BoundField DataField="THEATRE_CITY" HeaderText="City"                       SortExpression="THEATRE_CITY" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="panel panel-success">
                <div class="panel-heading"><strong>Insert New Theatre</strong></div>
                <div class="panel-body">
                    <asp:FormView ID="FormView1" runat="server"
                        DataKeyNames="THEATRE_ID"
                        DataSourceID="SqlDataSource1">

                        <ItemTemplate>
                            <asp:LinkButton ID="NewButton" runat="server"
                                CausesValidation="False" CommandName="New"
                                Text="+ New Theatre" CssClass="btn btn-success btn-sm" />
                        </ItemTemplate>

                        <InsertItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Theatre ID <span class="text-danger">*</span></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="THEATRE_IDTextBox" runat="server"
                                            Text='<%# Bind("THEATRE_ID") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. 16" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="THEATRE_IDTextBox"
                                            ValidationGroup="InsertTheatre"
                                            Display="None"
                                            ErrorMessage="Theatre ID is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="THEATRE_IDTextBox"
                                            ValidationGroup="InsertTheatre"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Theatre ID must be a whole number (e.g. 16)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Theatre Name <span class="text-danger">*</span></label>
                                    <div class="col-sm-6">
                                        <asp:TextBox ID="THEATRE_NAMETextBox" runat="server"
                                            Text='<%# Bind("THEATRE_NAME") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. Kumari Cinemas Pokhara" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="THEATRE_NAMETextBox"
                                            ValidationGroup="InsertTheatre"
                                            Display="None"
                                            ErrorMessage="Theatre Name is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">City <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:DropDownList ID="THEATRE_CITYDropDown" runat="server"
                                            SelectedValue='<%# Bind("THEATRE_CITY") %>'
                                            CssClass="form-control">
                                            <asp:ListItem Value="">-- Select City --</asp:ListItem>
                                            <asp:ListItem>Kathmandu</asp:ListItem>
                                            <asp:ListItem>Pokhara</asp:ListItem>
                                            <asp:ListItem>Biratnagar</asp:ListItem>
                                            <asp:ListItem>Lalitpur</asp:ListItem>
                                            <asp:ListItem>Bhaktapur</asp:ListItem>
                                            <asp:ListItem>Chitwan</asp:ListItem>
                                            <asp:ListItem>Butwal</asp:ListItem>
                                            <asp:ListItem>Nepalgunj</asp:ListItem>
                                            <asp:ListItem>Dharan</asp:ListItem>
                                            <asp:ListItem>Hetauda</asp:ListItem>
                                            <asp:ListItem>Itahari</asp:ListItem>
                                            <asp:ListItem>Damak</asp:ListItem>
                                            <asp:ListItem>Surkhet</asp:ListItem>
                                            <asp:ListItem>Ilam</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="THEATRE_CITYDropDown"
                                            ValidationGroup="InsertTheatre"
                                            InitialValue=""
                                            Display="None"
                                            ErrorMessage="City is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:ValidationSummary ID="vsTheatre" runat="server"
                                            ShowMessageBox="false" ShowSummary="true"
                                            DisplayMode="BulletList"
                                            ValidationGroup="InsertTheatre"
                                            CssClass="alert alert-danger"
                                            HeaderText="Please fix the following:" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:LinkButton ID="InsertButton" runat="server"
                                            CausesValidation="True" CommandName="Insert"
                                            ValidationGroup="InsertTheatre"
                                            Text="Insert" CssClass="btn btn-primary btn-sm" />
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

            <hr />
            <h3>&#129115; Hall Management</h3>

            <div class="panel panel-info">
                <div class="panel-heading"><strong>Hall List</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView2" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataKeyNames="HALL_ID"
                        DataSourceID="SqlDataSource2">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />
                            <asp:BoundField DataField="HALL_ID"       HeaderText="Hall ID"          ReadOnly="True" SortExpression="HALL_ID"       />
                            <asp:BoundField DataField="HALL_CAPACITY" HeaderText="Capacity (seats)"              SortExpression="HALL_CAPACITY" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="panel panel-success">
                <div class="panel-heading"><strong>Insert New Hall</strong></div>
                <div class="panel-body">
                    <asp:FormView ID="FormView2" runat="server"
                        DataKeyNames="HALL_ID"
                        DataSourceID="SqlDataSource2">

                        <ItemTemplate>
                            <asp:LinkButton ID="NewButton" runat="server"
                                CausesValidation="False" CommandName="New"
                                Text="+ New Hall" CssClass="btn btn-success btn-sm" />
                        </ItemTemplate>

                        <InsertItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Hall ID <span class="text-danger">*</span></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="HALL_IDTextBox" runat="server"
                                            Text='<%# Bind("HALL_ID") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. 16" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="HALL_IDTextBox"
                                            ValidationGroup="InsertHall"
                                            Display="None"
                                            ErrorMessage="Hall ID is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="HALL_IDTextBox"
                                            ValidationGroup="InsertHall"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Hall ID must be a whole number (e.g. 16)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Capacity <span class="text-danger">*</span> <small>(10&ndash;1000)</small></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="HALL_CAPACITYTextBox" runat="server"
                                            Text='<%# Bind("HALL_CAPACITY") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. 300" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="HALL_CAPACITYTextBox"
                                            ValidationGroup="InsertHall"
                                            Display="None"
                                            ErrorMessage="Hall Capacity is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="HALL_CAPACITYTextBox"
                                            ValidationGroup="InsertHall"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Hall Capacity must be a whole number (e.g. 300)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:ValidationSummary ID="vsHall" runat="server"
                                            ShowMessageBox="false" ShowSummary="true"
                                            DisplayMode="BulletList"
                                            ValidationGroup="InsertHall"
                                            CssClass="alert alert-danger"
                                            HeaderText="Please fix the following:" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:LinkButton ID="InsertButton" runat="server"
                                            CausesValidation="True" CommandName="Insert"
                                            ValidationGroup="InsertHall"
                                            Text="Insert" CssClass="btn btn-primary btn-sm" />
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
