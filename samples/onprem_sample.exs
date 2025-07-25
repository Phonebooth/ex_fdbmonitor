alias ExFdbmonitor.Fdbcli
alias ExFdbmonitor.Sandbox

require Logger

Sandbox.start()

sandbox = Sandbox.MultiRegion

#onprem_cluster = Sandbox.cluster_file("onprem", 0)
#cloud_cluster = Sandbox.cluster_file("cloud", 0)

onprem =
  sandbox.checkout("onprem",
    starting_port: 5050#,
    #conf_assigns: [dr: [source: onprem_cluster, destination: :self]]
  )

#cloud =
#  sandbox.checkout("cloud",
#    starting_port: 5060,
#    conf_assigns: [dr: [source: onprem_cluster, destination: :self]]
#  )

# fdbdr start -s .ex_fdbmonitor/onprem.0/etc/fdb.cluster -d .ex_fdbmonitor/cloud.0/etc/fdb.cluster
#{:ok, result} = Fdbcli.exec(:start, onprem_cluster)

#Logger.notice(result[:stdout])

:timer.sleep(5000)

{:nodes, nodes} = List.last(onprem)
Logger.notice(inspect(nodes))
Enum.each(nodes, fn node ->
  cluster_file = node.etc_dir <> "/fdb.cluster"
  {:ok, result} = Fdbcli.exec(cluster_file, "status json")
  Logger.notice(result[:stdout])
end)

:timer.sleep(100)

_anything = IO.gets("Input anything to tear down the DBs: ")

sandbox.checkin(onprem, drop?: true)
#sandbox.checkin(cloud, drop?: true)
