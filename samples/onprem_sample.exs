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
Logger.notice(result[:stderr])
node = Enum.fetch!(nodes,5)
cluster_file = node.etc_dir <> "/fdb.cluster"
is_replication_healthy? = sandbox.make_is_replication_healthy(cluster_file)
sandbox.poll_until_true(is_replication_healthy?, 3000)

{:ok, result} = Fdbcli.exec(cluster_file, "configure usable_regions=2")
Logger.notice(result[:stdout])
sandbox.poll_until_true(is_replication_healthy?, 3000)

{:ok, result} = Fdbcli.exec(cluster_file, "fileconfigure /tmp/regions2.json")
Logger.notice(result[:stdout])
sandbox.poll_until_true(is_replication_healthy?, 3000)

_anything = IO.gets("Input anything to tear down the DBs: ")

sandbox.checkin(onprem, drop?: true)
