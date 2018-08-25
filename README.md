# Tankinho

A sample UDP client for playing [rrobots](https://github.com/mmmries/rrobots).
You can see a demo of the game [here](https://youtu.be/MWC36pFxUrs).

## Getting Started

If you are playing the game on your own you will first need to [get a server started](https://github.com/mmmries/rrobots#usage).
If you are playing in a group you just need to get the address of the server.

### Cloned Repo
If you don't want to customize your own tank, you can just clone this repo and run examples:

```Bash
$ git clone https://github.com/mmmries/tankinho.git
$ cd tankinho
$ mix deps.get
$ mix tankinho.start --server 192.168.2.10:5566 --name Michael --tank Tankinho.ExampleTanks.Spinner
```

Just replace the server address above with the address where the server is running.

### As a Dependency
If you want to hang onto your tanks, Tankinho also works as a dependency in your own repo.

```Bash
$ mix new tanks
$ cd tanks
```

Add Tankinho to your dependencies:

```Elixir
defp deps do
  [
    {:tankinho, git: "https://github.com/mmmries/tankinho.git"}
  ]
end
```

At this point, you can install deps and run example tanks:

```Bash
$ mix deps.get
$ mix tankinho.start --server 192.168.2.10:5566 --name Michael --tank Tankinho.ExampleTanks.Spinner
```

Using the examples in `lib/tankinho/example_tanks/` for reference, create your own tank modules. You can then run them as you did the examples:

```Bash
$ mix tankinho.start --server 192.168.2.10:5566 --name Juggernaut --tank Tanks.Juggernaut
```

## Customizing Your Tank

Example tank implementations are available in `lib/tankinho/example_tanks/`.
Open an example and you can see a template.
The basic idea is that you have a module with two functions:

 * `init/1` function which is called when you join a game
 * `tick/2` function which is called once on each tick of a game

 ## Init Function

 The init function receives a single argument like:

 ```elixir
%{
  width:  800, #the height of the game in pixels
  height: 600, #the width of the game in pixels
  size:   60,  #the height/width of your robot in pixels
}
 ```

 This function will return a `state` term of anything you want to keep track of for the game.
 This same `state` will be passed to your `tick` function on the first tick of the game.

 ## Tick Function

The tick function is called 60 times per second (once for each frame of the game) and receives two arguments.
The first argument is the game state from the server (see details below).
The second argument is the current `state` of your tank.
 
The tick function is where your tank decides to take actions like turning, driving and shooting.
Each time your function is called it must return a tuple of: `{actions, new_state}`, and the `new_state` will be passed as the second argument the next time your `tick` function is called.

The `actions` you want to take is a `%Tankinho.Actions{}` struct.
You can take actions like this: `%Actions{} |> Actions.fire(1) |> Actions.accelerate(2.0)`.
For a full list of actions you can take, please see [the Actions module](https://github.com/mmmries/tankinho/blob/master/lib/tankinho/actions.ex).

## The Game State

The game state from the server provides information about where the tank is,
how much energy it has, and other details about the game board.
Here is an example of what the data looks like.

 ```elixir
%{
  "energy" =>        100,
  "gun_heading" =>   242.0,
  "heading" =>       242.0
  "radar_heading" => 242.0,
  "time" =>          416,
  "speed" =>         0,
  "x" =>             1764.0,
  "y" =>             60.0,
  "robots_scanned":  [1020.65],
  "broadcasts":      [["hi", "west"]],
}
 ```
