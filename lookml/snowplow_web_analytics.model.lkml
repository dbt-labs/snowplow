connection: "simba_redshift"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

 explore: snowplow_sessions {


 }
