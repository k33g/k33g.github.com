module dyno

struct dyno = { 
  fields,
  methods
}

augment dyno {
  function field = |this, name| {
    return this: fields(): get(name)
  }
  function field = |this, name, value| {
    this: fields(): put(name, value)
    return this
  }
  function run = |this, name| {
    return this: fields(): get(name)
  }
} 

function Dyno = {
  let d = dyno(map[], map[])
  d: methods(): put("hello", |arg| {
      println("yo" + arg)
    })
}


function main = |args| {
  # ...
  let bob = Dyno(): run("hello")(45)
}