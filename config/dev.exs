import Config

fdb_storage_engine = System.get_env("FDB_STORAGE_ENGINE") || "ssd-redwood-1-experimental"

config :ex_fdbmonitor,
  bootstrap: [
    cluster: [
      coordinator_addr: "127.0.0.1"
    ],
    conf: [
      data_dir: ".ex_fdbmonitor/dev/data",
      log_dir: ".ex_fdbmonitor/dev/log",
      fdbservers: [
        [port: 5000]
      ],
      fdb_storage_engine: fdb_storage_engine
    ],
    fdbcli: ~w[configure new single #{fdb_storage_engine} tenant_mode=optional_experimental]
  ]

config :ex_fdbmonitor,
  etc_dir: ".ex_fdbmonitor/dev/etc",
  run_dir: ".ex_fdbmonitor/dev/run"
