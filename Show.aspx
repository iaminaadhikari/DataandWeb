<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Show.aspx.cs" Inherits="KumariCinemas.Show" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ShowTimes Details &mdash; Kumari Cinemas</title>
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
      <li class="active"><a href="Show.aspx">&#9200; Show</a></li>
      <li><a href="Movie.aspx">&#127916; Movie</a></li>
      <li><a href="Ticket.aspx">&#127915; Ticket</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; Reports</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#9200; ShowTimes Details <small>Basic Form</small></h2>
    <p class="text-muted">Manage show schedules. Select a movie, theatre and hall when adding a new show.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT s."SHOW_ID", s."SHOW_TIMES", s."SHOW_DATE",
                               m."TITLE" AS MOVIE_TITLE, t."THEATRE_NAME", t."THEATRE_CITY",
                               h."HALL_ID", h."HALL_CAPACITY"
                               FROM "SHOW" s
                               LEFT JOIN "HALL_SHOW" hs ON hs."SHOW_ID"    = s."SHOW_ID"
                               LEFT JOIN "MOVIE"     m  ON m."MOVIE_ID"    = hs."MOVIE_ID"
                               LEFT JOIN "THEATRE"   t  ON t."THEATRE_ID"  = hs."THEATRE_ID"
                               LEFT JOIN "HALL"      h  ON h."HALL_ID"     = hs."HALL_ID"
                               ORDER BY s."SHOW_DATE", s."SHOW_TIMES"'
                UpdateCommand='UPDATE "SHOW" SET "SHOW_TIMES"=:SHOW_TIMES, "SHOW_DATE"=TO_DATE(:SHOW_DATE,&apos;YYYY-MM-DD&apos;) WHERE "SHOW_ID"=:SHOW_ID'
                DeleteCommand='DELETE FROM "SHOW" WHERE "SHOW_ID"=:SHOW_ID'
                OnDeleting="SqlDataSource1_Deleting"
                OnUpdating="SqlDataSource1_Updating"
                OnSelecting="SqlDataSource1_Selecting">
                <UpdateParameters>
                    <asp:Parameter Name="SHOW_TIMES" Type="String"  />
                    <asp:Parameter Name="SHOW_DATE"  Type="String"  />
                    <asp:Parameter Name="SHOW_ID"    Type="Decimal" />
                </UpdateParameters>
                <DeleteParameters>
                    <asp:Parameter Name="SHOW_ID" Type="Decimal" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <asp:Label ID="lblMsg" runat="server" Visible="false" />

            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Show Schedule (with Movie, Theatre, Hall links)</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataKeyNames="SHOW_ID"
                        DataSourceID="SqlDataSource1">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />
                            <asp:BoundField DataField="SHOW_ID"       HeaderText="Show ID"    ReadOnly="True" SortExpression="SHOW_ID"       />
                            <asp:BoundField DataField="SHOW_TIMES"    HeaderText="Time Slot"                  SortExpression="SHOW_TIMES"    />
                            <asp:BoundField DataField="SHOW_DATE"     HeaderText="Date"                       SortExpression="SHOW_DATE"     DataFormatString="{0:dd-MMM-yyyy}" />
                            <asp:BoundField DataField="MOVIE_TITLE"   HeaderText="Movie"      ReadOnly="True" />
                            <asp:BoundField DataField="THEATRE_NAME"  HeaderText="Theatre"    ReadOnly="True" />
                            <asp:BoundField DataField="THEATRE_CITY"  HeaderText="City"       ReadOnly="True" />
                            <asp:BoundField DataField="HALL_ID"       HeaderText="Hall ID"    ReadOnly="True" />
                            <asp:BoundField DataField="HALL_CAPACITY" HeaderText="Capacity"   ReadOnly="True" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="panel panel-success">
                <div class="panel-heading"><strong>Insert New Show</strong></div>
                <div class="panel-body">
                    <asp:FormView ID="FormView1" runat="server"
                        DataKeyNames="SHOW_ID"
                        OnItemInserting="FormView1_ItemInserting">

                        <ItemTemplate>
                            <asp:LinkButton ID="NewButton" runat="server"
                                CausesValidation="False" CommandName="New"
                                Text="+ New Show" CssClass="btn btn-success btn-sm" />
                        </ItemTemplate>

                        <InsertItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Show ID <span class="text-danger">*</span></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="SHOW_IDTextBox" runat="server"
                                            Text='<%# Bind("SHOW_ID") %>'
                                            CssClass="form-control" placeholder="e.g. 16" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="SHOW_IDTextBox"
                                            ValidationGroup="InsertShow" Display="None"
                                            ErrorMessage="Show ID is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="SHOW_IDTextBox"
                                            ValidationGroup="InsertShow"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Show ID must be a whole number (e.g. 16)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Time Slot <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:DropDownList ID="SHOW_TIMESDropDown" runat="server"
                                            SelectedValue='<%# Bind("SHOW_TIMES") %>'
                                            CssClass="form-control">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem Value="Morning">Morning (10:00 AM)</asp:ListItem>
                                            <asp:ListItem Value="Day">Day (2:00 PM)</asp:ListItem>
                                            <asp:ListItem Value="Evening">Evening (7:00 PM)</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="SHOW_TIMESDropDown"
                                            ValidationGroup="InsertShow" InitialValue=""
                                            Display="None" ErrorMessage="Time Slot is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Show Date <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:TextBox ID="SHOW_DATETextBox" runat="server"
                                            Text='<%# Bind("SHOW_DATE") %>'
                                            CssClass="form-control" TextMode="Date" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="SHOW_DATETextBox"
                                            ValidationGroup="InsertShow" Display="None"
                                            ErrorMessage="Show Date is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-12">
                                        <hr />
                                        <strong style="color:#337ab7;">Link to Movie, Theatre and Hall</strong>

                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Customer <span class="text-danger">*</span></label>
                                    <div class="col-sm-5">
                                        <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="ddlCustomer"
                                            ValidationGroup="InsertShow" InitialValue=""
                                            Display="None" ErrorMessage="Customer is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Movie <span class="text-danger">*</span></label>
                                    <div class="col-sm-5">
                                        <asp:DropDownList ID="ddlMovie" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="ddlMovie"
                                            ValidationGroup="InsertShow" InitialValue=""
                                            Display="None" ErrorMessage="Movie is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Theatre <span class="text-danger">*</span></label>
                                    <div class="col-sm-5">
                                        <asp:DropDownList ID="ddlTheatre" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="ddlTheatre"
                                            ValidationGroup="InsertShow" InitialValue=""
                                            Display="None" ErrorMessage="Theatre is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Hall <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:DropDownList ID="ddlHall" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="ddlHall"
                                            ValidationGroup="InsertShow" InitialValue=""
                                            Display="None" ErrorMessage="Hall is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:ValidationSummary ID="vsShow" runat="server"
                                            ShowMessageBox="false" ShowSummary="true"
                                            DisplayMode="BulletList"
                                            ValidationGroup="InsertShow"
                                            CssClass="alert alert-danger"
                                            HeaderText="Please fix the following:" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:LinkButton ID="InsertButton" runat="server"
                                            CausesValidation="True" CommandName="Insert"
                                            ValidationGroup="InsertShow"
                                            Text="Insert Show + Link" CssClass="btn btn-primary btn-sm" />
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
