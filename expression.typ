#import "science.typ" : display_float

#let expr_state = state("expr",(:))


/// defines a new label with a value
///
#let node(label, value, math : none) = {
  assert(type(label)== "string")
  assert(type(value) in ("float","integer"))
  assert(type(math) == "string" or math == none)
  math = if math == none {label} else {math}
  let _ = expr_state.update(
    i => {
      //i.insert(undefineddoesn'traiseerrors, (label : label, math : math, value : value, type : "node"))
      i.insert(label, (label : label, math : math, value : value, type : "node"))
      i
    }
  )
}

#let show_node(lab) = {
  locate( loc => {
    return expr_state.at(loc)

    if not expr_state.at(loc).at(lab) { panic() 
    } else {
      let node = expr_state.at(loc).at(lab)
      eval("$" + node.label + "=" + str(node.value) + "$")
    }
  })
}

#let expr_to_val(..nodes) = {
    // args must be string or node
    assert(nodes.pos().all(i => type(i) == "string" or is_node(i)))
    let v = "#{" + nodes.pos().map(i => if is_node(i) {str(i.value)} else {i}).join("") + "}"
    v
}

#let expr_to_label(..nodes) = {
    // args must be string or node
    assert(nodes.pos().all(i => type(i) == "string" or is_node(i)))
    let s = nodes.pos().map(i => if is_node(i) {i.label} else {i}).join(" ")
    s.replace("*","times")
}

#let expr_to_dev(..nodes) = {
    // args must be string or node
    assert(nodes.pos().all(i => type(i) == "string" or is_node(i)))
    let s = nodes.pos().map(i => if is_node(i) {str(i.value)} else {i}).join(" ")
    s.replace("*","times")
}



#let expression(
  x,
  digits : 4,
  show_labels : true,
  show_values : true,
  show_result : true
  ) = {
  locate(loc => {
    let nodes = expr_state.at(loc)
    return nodes
    let matches = x.matches(regex(":\\w"))
    let mathematize(x) = "$" + x +"$"

    let replace(value,q) = {
    let res = value
    for k in matches {
      let tok = k.text
       res = res.replace(tok,str(q(nodes.at(tok.trim(":")))))
    }
    res
    }
  
    let labels = if show_labels {
      replace(x,i=> i.label).replace("*","times") + " = " 
    } else { "" }

    let values = if show_values {
      replace(x,i=> i.value).replace("*","times") 
    } else { "" }


    
    let result = if show_result {
    let tmp = replace(x,i=> i.value)
    for m in tmp.matches(regex("(\\w|\\a)+\\^(\\w|\\a)+")) {
      tmp = tmp.replace(m.text, "calc.pow(" + m.text.split("^").at(0) +"," + m.text.split("^").at(1) + ")")
    }
    let tmp = eval(tmp) 
    
    " = " + display_float( digits : digits, tmp )
  } else {""}


  eval(mathematize(labels + values))  + result
  
  })
}
#let expr = expression

Example usage:

Let us consider #node("a", 10, math: "P_\"some\"")#show_node("a") m.s 
and #node("b", 5158);#show_node("b") m

Then: 
#expr(
  digits : 0,
  ":a^2 * :a^2",      
)

#locate(loc => expr_state.at(loc))
// #expr(":a") m


// #expr(
//   "(:a + :b)/ (:b)  - 5"
// )


// #expr(
//   "(:a * :b)/ (:b)  - 5",      
// )