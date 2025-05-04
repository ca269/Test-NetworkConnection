Ping Test Analyzer

Language: PowerShell
UI Framework: Windows Forms

Overview

Ping Test Analyzer is a graphical PowerShell utility that performs a user-defined number of ping tests to a specified domain or IP address (at 1-second intervals). It then plots the round-trip times on a line graph to help visualize latency trends and identify potential intermittent network issues.
Users can optionally export the chart as a PNG file directly to their Desktop for further analysis or reporting.
________________________________________
Features

GUI input for:

•	Number of pings to send

•	Target domain or IP address

•	Live progress display during the ping process

•	DNS resolution support (if a domain name is provided)

•	Dynamic line chart generation using Windows Forms Data Visualization

•	One-click export of the ping results as a PNG image

•	Designed to help identify sporadic network issues or performance fluctuations

________________________________________
Prerequisites

•	Windows OS

•	PowerShell 5.1+

•	.NET Framework (required for Windows Forms and Charting libraries)

•	Internet/network connectivity to the target domain or IP

________________________________________
How to Use
1.	Open PowerShell with sufficient privileges.
2.	Run the script directly:
3.	Enter:
•	The number of pings you want to send (1 ping/sec)
o	The domain name or IP address to ping
4.	View live progress as the tool gathers data.
5.	Once the test is complete, review the graph.
6.	Click "Export PNG to Desktop" to save the chart as an image.
________________________________________
Example Use Case

Suppose you're experiencing sporadic internet slowdowns or connectivity issues. Run this tool with a reasonable number of pings (e.g., 100) to a reliable site (e.g., 8.8.8.8) and review the graph to check for latency spikes or lost packets.
________________________________________
Screenshot

N/A
________________________________________
Known Limitations

•	Does not support IPv6-only domains.

•	Not designed for continuous long-term monitoring.

•	No CSV export (only graphical PNG export).

•	Must be run on a Windows system with a GUI (not suitable for headless environments).

________________________________________
License
This project is provided as-is with no warranty or support. Feel free to use, modify, or redistribute with attribution.

