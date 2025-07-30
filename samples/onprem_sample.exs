alias ExFdbmonitor.Fdbcli
alias ExFdbmonitor.Sandbox

require Logger

Sandbox.start()

sandbox = Sandbox.OnPrem


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

:timer.sleep(10000)

#{:nodes, nodes} = List.last(onprem)
#Logger.notice(inspect(nodes))
#Enum.each(nodes, fn node ->
#  cluster_file = node.etc_dir <> "/fdb.cluster"
#  {:ok, result} = Fdbcli.exec(cluster_file, "status json")
#  Logger.notice(result[:stdout])
#end)

{:nodes, nodes} = List.last(onprem)
node = List.first(nodes)
cluster_file = node.etc_dir <> "/fdb.cluster"
{:ok, result} = Fdbcli.exec(cluster_file, "exclude locality_dcid:dc2")
Logger.notice(result[:stdout])

:timer.sleep(1000)
{:ok, result} = Fdbcli.exec(cluster_file, "fileconfigure /tmp/regions1.json")
Logger.notice(result)

:timer.sleep(1000)

{:ok, result} = Fdbcli.exec(cluster_file, "include locality_dcid:dc2")
Logger.notice(result[:stdout])
node = Enum.fetch!(nodes,5)
cluster_file = node.etc_dir <> "/fdb.cluster"
replication_healthy = sandbox.make_replication_healthy(cluster_file)
sandbox.poll_until_true(replication_healthy, 3000)
#
#:timer.sleep(10000)

#{:ok, result} = :exec.run("fdbcli --exec 'status json' | jq .cluster.full_replication",[:sync, :stdout])
#full_replication = String.trim(List.first(result[:stdout]))
#message = "full_replication, #{full_replication}"
#Logger.notice(message)

{:ok, result} = Fdbcli.exec(cluster_file, "configure usable_regions=2")
Logger.notice(result[:stdout])
sandbox.poll_until_true(replication_healthy, 3000)

{:ok, result} = Fdbcli.exec(cluster_file, "fileconfigure /tmp/regions2.json")
Logger.notice(result[:stdout])
sandbox.poll_until_true(replication_healthy, 3000)

_anything = IO.gets("Input anything to tear down the DBs: ")

sandbox.checkin(onprem, drop?: true)
