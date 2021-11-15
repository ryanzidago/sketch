# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sketch.Repo.insert!(%Sketch.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Sketch.{Canvas, CanvasRepo}

uuids = ~w(
  57435f41-e9ef-4d4f-9c29-a242408323f3
  e0cd2d97-647e-4bf1-b8e2-6c5a3dfbc36b
  37bf86bc-7a4a-4421-a243-af1914142ac2
  )

for uuid <- uuids do
  canvas =
    if uuid == "37bf86bc-7a4a-4421-a243-af1914142ac2" do
      Canvas.new({21, 8})
    else
      Canvas.new()
    end

  canvas
  |> Map.put(:id, uuid)
  |> CanvasRepo.insert!()
end
