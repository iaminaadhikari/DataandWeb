<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Movie.aspx.cs" Inherits="KumariCinemas.Movie" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Movie Details &mdash; Kumari Cinemas</title>
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
      <li class="active"><a href="Movie.aspx">&#127916; Movie</a></li>
      <li><a href="Ticket.aspx">&#127915; Ticket</a></li>
      <li><a href="UserTicketReport.aspx">&#127903; Reports</a></li>
    </ul>
  </div>
</nav>

<div class="container">
    <h2>&#127916; Movie Details <small>Basic Form</small></h2>
    <p class="text-muted">Add, view, update and delete movie records.</p>
    <hr />

    <form id="form1" runat="server">
        <div>

            <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>"
                SelectCommand='SELECT "MOVIE_ID", "TITLE", "DURATION", "LANGUAGE", "GENRE", "RELEASE_DATE" FROM "MOVIE" ORDER BY "MOVIE_ID"'
                InsertCommand='INSERT INTO "MOVIE" ("MOVIE_ID", "TITLE", "DURATION", "LANGUAGE", "GENRE", "RELEASE_DATE") VALUES (:MOVIE_ID, :TITLE, :DURATION, :LANGUAGE, :GENRE, TO_DATE(:RELEASE_DATE,&apos;YYYY-MM-DD&apos;))'
                UpdateCommand='UPDATE "MOVIE" SET "TITLE"=:TITLE, "DURATION"=:DURATION, "LANGUAGE"=:LANGUAGE, "GENRE"=:GENRE, "RELEASE_DATE"=TO_DATE(:RELEASE_DATE,&apos;YYYY-MM-DD&apos;) WHERE "MOVIE_ID"=:MOVIE_ID'
                DeleteCommand='DELETE FROM "MOVIE" WHERE "MOVIE_ID"=:MOVIE_ID'
                OnSelecting="SqlDataSource1_Selecting"
                OnInserted="SqlDataSource1_Inserted"
                OnUpdating="SqlDataSource1_Updating"
                OnDeleting="SqlDataSource1_Deleting">
                <InsertParameters>
                    <asp:Parameter Name="MOVIE_ID"     Type="Decimal" />
                    <asp:Parameter Name="TITLE"        Type="String"  />
                    <asp:Parameter Name="DURATION"     Type="Decimal" />
                    <asp:Parameter Name="LANGUAGE"     Type="String"  />
                    <asp:Parameter Name="GENRE"        Type="String"  />
                    <asp:Parameter Name="RELEASE_DATE" Type="String"  />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="TITLE"        Type="String"  />
                    <asp:Parameter Name="DURATION"     Type="Decimal" />
                    <asp:Parameter Name="LANGUAGE"     Type="String"  />
                    <asp:Parameter Name="GENRE"        Type="String"  />
                    <asp:Parameter Name="RELEASE_DATE" Type="String"  />
                    <asp:Parameter Name="MOVIE_ID"     Type="Decimal" />
                </UpdateParameters>
                <DeleteParameters>
                    <asp:Parameter Name="MOVIE_ID"     Type="Decimal" />
                </DeleteParameters>
            </asp:SqlDataSource>

            <asp:Label ID="lblMsg" runat="server" Visible="false" />

            <div class="panel panel-primary">
                <div class="panel-heading"><strong>Movie List</strong></div>
                <div class="panel-body">
                    <asp:GridView ID="GridView1" runat="server"
                        CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False"
                        DataKeyNames="MOVIE_ID"
                        DataSourceID="SqlDataSource1">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" />
                            <asp:BoundField DataField="MOVIE_ID"     HeaderText="Movie ID"       ReadOnly="True" SortExpression="MOVIE_ID"     />
                            <asp:BoundField DataField="TITLE"        HeaderText="Title"                          SortExpression="TITLE"        />
                            <asp:BoundField DataField="DURATION"     HeaderText="Duration (min)"                 SortExpression="DURATION"     />
                            <asp:BoundField DataField="LANGUAGE"     HeaderText="Language"                       SortExpression="LANGUAGE"     />
                            <asp:BoundField DataField="GENRE"        HeaderText="Genre"                          SortExpression="GENRE"        />
                            <asp:BoundField DataField="RELEASE_DATE" HeaderText="Release Date"                   SortExpression="RELEASE_DATE" DataFormatString="{0:dd-MMM-yyyy}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="panel panel-success">
                <div class="panel-heading"><strong>Insert New Movie</strong></div>
                <div class="panel-body">
                    <asp:FormView ID="FormView1" runat="server"
                        DataKeyNames="MOVIE_ID"
                        DataSourceID="SqlDataSource1">

                        <ItemTemplate>
                            <asp:LinkButton ID="NewButton" runat="server"
                                CausesValidation="False" CommandName="New"
                                Text="+ New Movie" CssClass="btn btn-success btn-sm" />
                        </ItemTemplate>

                        <InsertItemTemplate>
                            <div class="form-horizontal">

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Movie ID <span class="text-danger">*</span></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="MOVIE_IDTextBox" runat="server"
                                            Text='<%# Bind("MOVIE_ID") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. 16" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="MOVIE_IDTextBox"
                                            ValidationGroup="InsertMovie"
                                            Display="None"
                                            ErrorMessage="Movie ID is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="MOVIE_IDTextBox"
                                            ValidationGroup="InsertMovie"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Movie ID must be a whole number (e.g. 16)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Title <span class="text-danger">*</span></label>
                                    <div class="col-sm-6">
                                        <asp:TextBox ID="TITLETextBox" runat="server"
                                            Text='<%# Bind("TITLE") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. Pushpa 2" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="TITLETextBox"
                                            ValidationGroup="InsertMovie"
                                            Display="None"
                                            ErrorMessage="Title is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Duration (min) <span class="text-danger">*</span></label>
                                    <div class="col-sm-3">
                                        <asp:TextBox ID="DURATIONTextBox" runat="server"
                                            Text='<%# Bind("DURATION") %>'
                                            CssClass="form-control"
                                            placeholder="e.g. 145" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="DURATIONTextBox"
                                            ValidationGroup="InsertMovie"
                                            Display="None"
                                            ErrorMessage="Duration is required." />
                                        <asp:CompareValidator runat="server"
                                            ControlToValidate="DURATIONTextBox"
                                            ValidationGroup="InsertMovie"
                                            Operator="DataTypeCheck" Type="Integer"
                                            Display="None"
                                            ErrorMessage="Duration must be a whole number (e.g. 145)." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Language <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:DropDownList ID="LANGUAGEDropDown" runat="server"
                                            SelectedValue='<%# Bind("LANGUAGE") %>'
                                            CssClass="form-control">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem>Hindi</asp:ListItem>
                                            <asp:ListItem>English</asp:ListItem>
                                            <asp:ListItem>Nepali</asp:ListItem>
                                            <asp:ListItem>Tamil</asp:ListItem>
                                            <asp:ListItem>Telugu</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="LANGUAGEDropDown"
                                            ValidationGroup="InsertMovie"
                                            InitialValue=""
                                            Display="None"
                                            ErrorMessage="Language is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Genre <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:DropDownList ID="GENREDropDown" runat="server"
                                            SelectedValue='<%# Bind("GENRE") %>'
                                            CssClass="form-control">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem>Action</asp:ListItem>
                                            <asp:ListItem>Drama</asp:ListItem>
                                            <asp:ListItem>Comedy</asp:ListItem>
                                            <asp:ListItem>Thriller</asp:ListItem>
                                            <asp:ListItem>Sci-Fi</asp:ListItem>
                                            <asp:ListItem>Animation</asp:ListItem>
                                            <asp:ListItem>Historical</asp:ListItem>
                                            <asp:ListItem>Romance</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="GENREDropDown"
                                            ValidationGroup="InsertMovie"
                                            InitialValue=""
                                            Display="None"
                                            ErrorMessage="Genre is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-sm-3 control-label">Release Date <span class="text-danger">*</span></label>
                                    <div class="col-sm-4">
                                        <asp:TextBox ID="RELEASE_DATETextBox" runat="server"
                                            Text='<%# Bind("RELEASE_DATE") %>'
                                            CssClass="form-control"
                                            TextMode="Date" />
                                        <asp:RequiredFieldValidator runat="server"
                                            ControlToValidate="RELEASE_DATETextBox"
                                            ValidationGroup="InsertMovie"
                                            Display="None"
                                            ErrorMessage="Release Date is required." />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:ValidationSummary ID="vsInline" runat="server"
                                            ShowMessageBox="false" ShowSummary="true"
                                            DisplayMode="BulletList"
                                            ValidationGroup="InsertMovie"
                                            CssClass="alert alert-danger"
                                            HeaderText="Please fix the following:" />
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-3 col-sm-9">
                                        <asp:LinkButton ID="InsertButton" runat="server"
                                            CausesValidation="True" CommandName="Insert"
                                            ValidationGroup="InsertMovie"
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
