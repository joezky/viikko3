#!/usr/bin/env bash

# Palvelimen tietojen kerääminen
GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S %Z (%z)')
UPTIME_TEXT=$(uptime -p)

DISK_USAGE=$(df -P / | awk 'NR==2 {print $5}')
DISK_PERCENT=${DISK_USAGE%\%}

MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/ {print $7}')

# Funktio levyn tilan tarkistamiseen
check_disk_status() {
    local usage=$1

    if [ "$usage" -ge 80 ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

DISK_STATUS=$(check_disk_status "$DISK_PERCENT")

# HTML-raportin tiedostopolut
OUTPUT_FILE="/var/www/html/viikko3/index.html"
GITHUB_URL="https://github.com/joezky/viikko3"

# Create a temporary HTML file
TEMP_FILE=$(mktemp /var/www/html/viikko3/.report.XXXXXX)

# Generate the HTML report
cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Week 3 - Server Status Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #edf2f7;
            color: #243447;
            margin: 0;
            padding: 40px 20px;
        }
        .container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        h1, h2 {
            color: #1769aa;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background: #e7f1fb;
        }
        section {
            margin-top: 30px;
        }
        a {
            color: #1769aa;
        }
    </style>
</head>
<body>
<div class="container">

    <h1>Week 3: Server Status Report</h1>
    <p>
        This page displays information about my Linux server.
        The report is generated using a Bash script.
    </p>

    <section>
        <h2>Current Server Status</h2>
        <table>
            <tr><th>Information</th><th>Value</th></tr>
            <tr><td>Report generated</td><td>$GENERATED_AT</td></tr>
            <tr><td>Server uptime</td><td>$UPTIME_TEXT</td></tr>
            <tr><td>Root filesystem disk usage</td><td>$DISK_USAGE</td></tr>
            <tr><td>Disk space status</td><td>$DISK_STATUS</td></tr>
            <tr><td>Total RAM</td><td>$MEM_TOTAL MiB</td></tr>
            <tr><td>Available RAM</td><td>$MEM_AVAILABLE MiB</td></tr>
        </table>
        <p>
            Disk status is OK below 80% usage
            and WARNING at 80% or above.
        </p>
    </section>

    <section>
        <h2>Commands Used</h2>
        <p><strong>date:</strong> Shows the current date and time.</p>
        <p><strong>uptime -p:</strong> Shows how long the server has been running.</p>
        <p><strong>df -P /:</strong> Shows root filesystem disk usage.</p>
        <p><strong>free -m:</strong> Shows total and available RAM.</p>
    </section>

    <section>
        <h2>How the Script Works</h2>
        <p>
            The Bash script collects server information
            using Linux commands and stores the results
            in variables. Command substitution is used
            to save the command output.
        </p>
        <p>
            A function checks the disk usage with an
            if statement. If disk usage is 80% or more,
            the status is WARNING. Otherwise, it is OK.
        </p>
        <p>
            The script also uses pipes to process
            command output with awk.
        </p>
    </section>

    <section>
        <h2>Scheduling</h2>
    <p>
        I used cron to run the Bash script
        automatically every minute.
        The crontab contains the following command:
    </p>

    <p>
        <code>* * * * * /usr/bin/bash
        /home/ubuntu/viikko3/report.sh</code>
    </p>

    <p>
        Cron is enabled to start automatically
        when the server boots. I tested this
        by rebooting the virtual machine.
        The report continued updating after reboot.
        </p>
    </section>

    <section>
        <h2>Test Results</h2>

    <h3>Syntax Check and Manual Execution</h3>
    <p>
        The Bash script was checked using bash -n
        and executed manually. The script generated
        the HTML report successfully.
    </p>

    <h3>Disk Space Status Tests</h3>
    <p>
        The disk status function was tested using
        three different values.
    </p>

    <table>
        <tr>
            <th>Test Input</th>
            <th>Expected</th>
            <th>Actual Result</th>
        </tr>
        <tr>
            <td>50%</td>
            <td>OK</td>
            <td>OK</td>
        </tr>
        <tr>
            <td>80%</td>
            <td>WARNING</td>
            <td>WARNING</td>
        </tr>
        <tr>
            <td>90%</td>
            <td>WARNING</td>
            <td>WARNING</td>
        </tr>
    </table>

    <p>All three tests passed successfully.</p>

    <h3>Automatic Updates</h3>
    <p>
        Cron runs the Bash script every minute.
        I checked the report generation time
        and confirmed that it changed automatically
        after refreshing the page.
    </p>

    <h3>Reboot Test</h3>
    <p>
        I rebooted the virtual machine and checked
        that Nginx, Flask, MariaDB and cron
        started automatically.
        The Week 2 application and Week 3 report
        were accessible after the reboot.
        The report continued updating automatically.
        </p>
    </section>

    <section>
        <h2>What I Learned</h2>
        <p>
            I learned how to use Bash commands
            to collect information about a Linux server
            and generate an HTML report.
        </p>
    </section>

    <p>
        <a href="$GITHUB_URL">View Source Code on GitHub</a>
    </p>

</div>
</body>
</html>
EOF
#Allow Nginx to read the generated report
chmod 644 "$TEMP_FILE"

# Replace the previous report with the new one
mv -f "$TEMP_FILE" "$OUTPUT_FILE"
