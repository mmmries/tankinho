{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: {{127,0,0,1}, 5566},
  name: "tank1",
  port: 5567,
})
{:ok, _} = Tankinho.Client.start_link(%{
  server_addr: {{127,0,0,1}, 5566},
  name: "tank2",
  port: 5568,
})
Process.sleep(1_000_000_000)
