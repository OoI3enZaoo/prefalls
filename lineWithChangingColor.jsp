<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>amCharts examples</title>
        <link rel="stylesheet" href="style.css" type="text/css">
        <script src="js/amcharts/amcharts.js" type="text/javascript"></script>
        <script src="js/amcharts/serial.js" type="text/javascript"></script>

        <script>

            // since v3, chart can accept data in JSON format
            // if your category axis parses dates, you should only
            // set date format of your data (dataDateFormat property of AmSerialChart)
            var chartData = [
                {
                    "lineColor": "#ffc321",
                    "date": "1325470792000",
                    "duration": 408
                },
                {
                    "date": "1325470795000",
                    "duration": 482
                },
                {
                    "date": "1325470798000",
                    "duration": 562
                },
                {
                    "date": "1325470801000",
                    "duration": 379
                },
                {
                    "lineColor": "#fd813c",
                    "date": "1325470804000",
                    "duration": 501
                },
                {
                    "date": "1325470807000",
                    "duration": 443
                },
                {
                    "date": "1325470810000",
                    "duration": 405
                },
                {
                    "date": "1325470813000",
                    "duration": 309,
                    "lineColor": "#CC0000"
                },
                {
                    "date": "1325470816000",
                    "duration": 287
                },
                {
                    "date": "1325470819000",
                    "duration": 485
                },
                {
                    "date": "1325470822000",
                    "duration": 890
                },
                {
                    "date": "1325470825000",
                    "duration": 810
                }
            ];
            var chart;

            AmCharts.ready(function () {
                // SERIAL CHART
                chart = new AmCharts.AmSerialChart();
                chart.dataProvider = chartData;

                chart.categoryField = "date";
                chart.dataDateFormat = "HH:NN";

                var balloon = chart.balloon;
                balloon.cornerRadius = 6;
                balloon.adjustBorderColor = false;
                balloon.horizontalPadding = 10;
                balloon.verticalPadding = 10;

                // AXES
                // category axis
                var categoryAxis = chart.categoryAxis;
                categoryAxis.parseDates = true; // as our data is date-based, we set parseDates to true
                categoryAxis.minPeriod = "SS"; // our data is daily, so we set minPeriod to DD
                categoryAxis.autoGridCount = false;
                categoryAxis.gridCount = 50;
                categoryAxis.gridAlpha = 0;
                categoryAxis.gridColor = "#000000";
                categoryAxis.axisColor = "#555555";
                // we want custom date formatting, so we change it in next line
                categoryAxis.dateFormats = [{
                    period: 'DD',
                    format: 'DD'
                }, {
                    period: 'WW',
                    format: 'MMM DD'
                }, {
                    period: 'MM',
                    format: 'MMM'
                }, {
                    period: 'YYYY',
                    format: 'YYYY'
                }];

                // as we have data of different units, we create two different value axes
                // Duration value axis
                var durationAxis = new AmCharts.ValueAxis();
                durationAxis.gridAlpha = 0.05;
                durationAxis.axisAlpha = 0;
                // the following line makes this value axis to convert values to duration
                // it tells the axis what duration unit it should use. mm - minute, hh - hour...
                durationAxis.duration = "mm";
                durationAxis.durationUnits = {
                    DD: "d. ",
                    hh: "h ",
                    mm: "min",
                    ss: ""
                };
                chart.addValueAxis(durationAxis);


                // GRAPHS
                // duration graph
                var durationGraph = new AmCharts.AmGraph();
                durationGraph.title = "duration";
                durationGraph.valueField = "duration";
                durationGraph.type = "line";
                durationGraph.valueAxis = durationAxis; // indicate which axis should be used
                durationGraph.lineColorField = "lineColor";
                durationGraph.fillColorsField = "lineColor";
                durationGraph.fillAlphas = 0.3;
                durationGraph.balloonText = "[[value]]";
                durationGraph.lineThickness = 1;
                durationGraph.legendValueText = "[[value]]";
                durationGraph.bullet = "square";
                durationGraph.bulletBorderThickness = 1;
                durationGraph.bulletBorderAlpha = 1;
                chart.addGraph(durationGraph);

                // CURSOR
                var chartCursor = new AmCharts.ChartCursor();
                chartCursor.zoomable = false;
                chartCursor.categoryBalloonDateFormat = "YYYY MMM DD";
                chartCursor.cursorAlpha = 0;
                chart.addChartCursor(chartCursor);


                var chartScrollbar = new AmCharts.ChartScrollbar();
                chart.addChartScrollbar(chartScrollbar);

                // WRITE
                chart.write("chartdiv");
            });
        </script>
    </head>

    <body>
        <div id="chartdiv" style="width:100%; height:400px;"></div>
    </body>

</html>