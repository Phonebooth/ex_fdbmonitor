defmodule ExFdbmonitor.Sandbox.OnPrem do
  alias ExFdbmonitor.Sandbox
  import JSON

  @n 18
  @max_m 12

  @dc1 "dc1"
  @dc1sat "dc1sat"
  @dc2 "dc2"

  @regions [
    datacenters: [
      %{
        id: @dc1,
        priority: 1,
        satellite: 1,
        satellite_logs: 2
      }
    ],
    satellite_redundancy_mode: "one_satellite_double",
    satellite_logs: 2
  ]

  File.write!("/tmp/regions-onprem.json", JSON.encode!(@regions))

  def checkout(name, options \\ []) do
    Sandbox.checkout(name, @n, config: [ex_fdbmonitor: &config(&1, &2, name, options)])
  end

  def checkin(sandbox, options \\ []) do
    Sandbox.checkin(sandbox, options)
  end

  defp cluster_config(0), do: [coordinator_addr: "127.0.0.1"]
  defp cluster_config(_), do: :autojoin

  defp config(x, node, name, options) when x >= 0 and x < 6 do
    dc1_config(x, node, name, options)
  end

  defp config(x, node, name, options) when x >= 6 and x < 9 do
    dc1sat_config(x, node, name, options)
  end

  defp config(x, node, name, options) when x >= 9 and x < 15 do
    dc2_config(x, node, name, options)
  end

  defp config(x, node, name, options) when x >= 15 and x < 18 do
    dc3_config(x, node, name, options)
  end

  defp dc1_config(x, _node, name, options) do
    starting_port = Keyword.get(options, :starting_port, 5000)
    conf_assigns = Keyword.get(options, :conf_assigns, [])

    [
      bootstrap: [
        cluster: cluster_config(x),
        conf:
          Keyword.merge(
            [
              data_dir: Sandbox.data_dir(name, x),
              log_dir: Sandbox.log_dir(name, x),
              datacenter_id: @dc1,
              fdbservers: [
                [port: starting_port + x * @max_m + 0, class: :stateless],
                [port: starting_port + x * @max_m + 1, class: :stateless],
                [port: starting_port + x * @max_m + 2, class: :stateless],
                [port: starting_port + x * @max_m + 3, class: :transaction],
                [port: starting_port + x * @max_m + 4, class: :transaction],
                [port: starting_port + x * @max_m + 5, class: :transaction],
                [port: starting_port + x * @max_m + 6, class: :storage],
                [port: starting_port + x * @max_m + 7, class: :storage],
                [port: starting_port + x * @max_m + 8, class: :storage],
                [port: starting_port + x * @max_m + 9, class: :storage],
                [port: starting_port + x * @max_m + 10, class: :storage],
                [port: starting_port + x * @max_m + 11, class: :storage],
                [port: starting_port + x * @max_m + 12, class: :storage]
              ]
            ],
            conf_assigns
          ),
        fdbcli:
          if(x == 0, do: ~w[configure new single ssd-redwood-1 tenant_mode=optional_experimental]),
        fdbcli: if(x == 5, do: ~w[configure triple])
      ],
      etc_dir: Sandbox.etc_dir(name, x),
      run_dir: Sandbox.run_dir(name, x)
    ]
  end

  defp dc1sat_config(x, _node, name, options) do
    starting_port = Keyword.get(options, :starting_port, 5000)
    conf_assigns = Keyword.get(options, :conf_assigns, [])

    [
      bootstrap: [
        cluster: cluster_config(x),
        conf:
          Keyword.merge(
            [
              data_dir: Sandbox.data_dir(name, x),
              log_dir: Sandbox.log_dir(name, x),
              datacenter_id: @dc1sat,
              fdbservers: [
                [port: starting_port + x * @max_m + 0, class: :transaction]
              ]
            ],
            conf_assigns
          )
      ],
      etc_dir: Sandbox.etc_dir(name, x),
      run_dir: Sandbox.run_dir(name, x)
    ]
  end

  defp dc2_config(x, _node, name, options) do
    starting_port = Keyword.get(options, :starting_port, 5000)
    conf_assigns = Keyword.get(options, :conf_assigns, [])

    [
      bootstrap: [
        cluster: cluster_config(x),
        conf:
          Keyword.merge(
            [
              data_dir: Sandbox.data_dir(name, x),
              log_dir: Sandbox.log_dir(name, x),
              datacenter_id: @dc2,
              fdbservers: [
                [port: starting_port + x * @max_m + 0, class: :stateless],
                [port: starting_port + x * @max_m + 1, class: :stateless],
                [port: starting_port + x * @max_m + 2, class: :stateless],
                [port: starting_port + x * @max_m + 3, class: :transaction],
                [port: starting_port + x * @max_m + 4, class: :transaction],
                [port: starting_port + x * @max_m + 5, class: :transaction],
                [port: starting_port + x * @max_m + 6, class: :storage],
                [port: starting_port + x * @max_m + 7, class: :storage],
                [port: starting_port + x * @max_m + 8, class: :storage],
                [port: starting_port + x * @max_m + 9, class: :storage],
                [port: starting_port + x * @max_m + 10, class: :storage],
                [port: starting_port + x * @max_m + 11, class: :storage],
                [port: starting_port + x * @max_m + 12, class: :storage]
              ]
            ],
            conf_assigns
          )
      ],
      etc_dir: Sandbox.etc_dir(name, x),
      run_dir: Sandbox.run_dir(name, x)
    ]
  end

  defp dc3_config(x, _node, name, options) do
    starting_port = Keyword.get(options, :starting_port, 5000)
    conf_assigns = Keyword.get(options, :conf_assigns, [])

    [
      bootstrap: [
        cluster: cluster_config(x),
        conf:
          Keyword.merge(
            [
              data_dir: Sandbox.data_dir(name, x),
              log_dir: Sandbox.log_dir(name, x),
              datacenter_id: @dc3,
              fdbservers: [
                [port: starting_port + x * @max_m + 0, class: :stateless]
              ]
            ],
            conf_assigns
          ),
        fdbcli:
          if(x == 17,
            do:
              ~w[coordinators 127.0.0.1:5000 127.0.0.1:5012 127.0.0.1:5024 127.0.0.1:5108 127.0.0.1:5120 127.0.0.1:5132 127.0.0.1:5180 127.0.0.1:5192 127.0.0.1:5204]
          )
      ],
      etc_dir: Sandbox.etc_dir(name, x),
      run_dir: Sandbox.run_dir(name, x)
    ]
  end
end
