#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

# Create a CGI object
my $cgi = CGI->new;

# Database connection parameters
my $db_host = "your_database_host";
my $db_name = "your_database_name";
my $db_user = "your_database_user";
my $db_pass = "your_database_password";

# Connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$db_host", $db_user, $db_pass)
  or die "Unable to connect to database: $DBI::errstr";

# Fetch student data from the database
my $students_query = $dbh->prepare("SELECT * FROM students");
$students_query->execute;

# Print the HTML header
print $cgi->header('text/html');

# Print the HTML content
print <<HTML;
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>School Fees Management</title>
  <style>
    table {
      border-collapse: collapse;
      width: 100%;
    }

    th, td {
      border: 1px solid #dddddd;
      text-align: left;
      padding: 8px;
    }

    th {
      background-color: #f2f2f2;
    }
  </style>
</head>
<body>

  <h1>School Fees Management</h1>

  <form method="post">
    <label for="student_id">Select Student:</label>
    <select name="student_id">
HTML

# Display dropdown to select a student
while (my $row = $students_query->fetchrow_hashref) {
    print "<option value='$row->{StudentID}'>$row->{Name}</option>";
}

# Continue printing HTML
print <<HTML;
    </select>
    <input type="submit" name="refresh_btn" value="Refresh">
  </form>

HTML

# Display fees information in a table
if ($cgi->param('student_id')) {
    my $selected_student_id = $cgi->param('student_id');
    my $fees_query = $dbh->prepare("SELECT * FROM students WHERE StudentID = ?");
    $fees_query->execute($selected_student_id);

    print "<h2>Fees Information</h2>";
    print "<table>";
    print "<tr><th>StudentID</th><th>Name</th><th>FeesPaid</th><th>TotalFees</th></tr>";

    while (my $fees_row = $fees_query->fetchrow_hashref) {
        print "<tr><td>$fees_row->{StudentID}</td><td>$fees_row->{Name}</td><td>$fees_row->{FeesPaid}</td><td>$fees_row->{TotalFees}</td></tr>";
    }

    print "</table>";
}

# Close the database connection
$dbh->disconnect;

# Print the HTML footer
print <<HTML;
</body>
</html>
HTML
