owner = "ncarballal"

project = "dataengineer-challenge"

raw_table_name = "FakeBank_api"

spark_arguments = {
    "--enable-auto-scaling"               = "true"
    "--enable-job-insights"               = "false"
    "--job-language"                      = "python"
    "--extra-jars"                        = null
    "--enable-continuous-cloudwatch-log"  = "true"
    "--enable-metrics"                    = "true"
    "--enable-observability-metrics"      = "true"
}