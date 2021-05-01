include karax/prelude
import karax / [karaxdsl, kdom, vdom, vstyles]
import sequtils, random, times

type
  TextVariant* = enum
    Input
    TextArea

  BooleanVariant* = enum
    Checkbox
    Radio

  EnumVariant* = enum
    Option
    DataList
    FieldSet

proc id_seed*(vnode: VNode, seed:int = 20): VNode =
  result = vnode
  result.setAttr("id", $(0..seed).toSeq.sample)
  return result

when defined(js):

  proc optionsMenu(name, message, id: cstring, selected = "", options: seq[string], disabled = false): VNode =
      ## generate a drop-down menu.
      ## name plugs into label wrapper around drop-down menu, and select id
      ## message is what you first see selected on the dropdown.
      ## selected is just which of the options is selected (if you don't want a message)
      ## options are just the other options

      result = buildHtml():
        label(`for` = $name, id = $id):
          if disabled:
            select(id = $name, disabled = ""):
              if message.len > 0:
                  option(value = ""):
                      text $message

              for index, option in options:
                  if option == selected:
                      option(value = selected, selected = "selected"):
                          text selected
                  else:
                      option(value = option):
                        text option

          else:
            select(id = $name):
              if message.len > 0:
                option(value = ""):
                  text $message

              for index, option in options:
                if option == selected:
                  option(value = selected, selected = "selected"):
                      text selected
                else:
                  option(value = option):
                    text option

  proc dataList(selected: cstring, options: seq[string], name: cstring, id = (0..1000).rand, disabled = false): VNode =
    let list_id = "list_" & $id

    if disabled:
      result = buildHtml():
        input(list = list_id, disabled = $disabled, value = selected)
    else:
      result = buildHtml(tdiv):
        input(list = list_id, value = selected)
        datalist(id = list_id):
          for option in options:
            if option == selected:
              option(value = option, selected="true")
            else:
              option(value = option)

  proc fieldSet(selected: cstring, options: seq[string], name: cstring, id = (0..1000).rand, disabled = false): VNode =
    let list_id = "list_" & $id

    result = buildHtml(tdiv):
      input(type = "radio", id=list_id, name=name, value=selected, checked="checked", disabled=($disabled))
      for index, option in options:
        input(`type` = "radio", id=($index & list_id), name=name, value=selected)
        label(`for`=option):
          text option

  ##############
  ### Update ###
  ##############

  proc update*(elem: bool, variant = Checkbox, id = (0..100).rand): VNode =
    result = case(variant):
      of Checkbox: buildHtml(input(`type` = "checkbox", id = $id))
      of Radio: buildHtml(input(`type` = "radio", id = $id))
    
    if elem:
      result.setAttr("checked", "true")

  proc update*(elem: string, variant = Input, id = (0..100).rand): VNode =
    result = case(variant):
      of Input: buildHtml(input(type = "text", value = elem, id = $id))
      of TextArea: buildHtml(textarea(value = elem, id = $id))

  proc update*(elem: int): VNode =
    buildHtml(input(type = "number", value = $elem))

  proc update*(elem: int, id: string): VNode =
    buildHtml(input(type = "number", value = $elem, id = $id))

  proc update*(elem: enum, variant = Option, id = (0..100).rand, disabled = false): VNode =
    let options = (elem.typeof.low..elem.typeof.high).mapIt($it)

    result = case(variant):
      of Option:
        buildHtml(
          optionsMenu(
            name = $elem.typeof, 
            message = "", 
            id = $id,
            selected = $elem, 
            options = options,
            disabled = disabled
          ))
      of DataList:
        buildHtml(
          dataList($elem, options, $elem.typeof, id = id, disabled = disabled)
        )
      of FieldSet:
        buildHtml(
          fieldSet($elem.typeof, options, $elem.typeof, disabled = disabled)
        )

  proc update*(elems: seq[string], id = (0..100).rand): VNode =
    result = buildHtml(
      optionsMenu(
        name = "string array",
        message = "",
        id = $(0..elems.len).toSeq,
        selected = $(elems[0]),
        options = elems
    ))

  proc update*[T: HSlice](x: T, default = 0, id = (0..100).rand): VNode =
    let range_seq = x.toSeq
    result = buildHtml(
      input(
        `type` = "range", 
        id = "range", 
        min = $(range_seq.low), 
        max = $(range_seq.high),
        value = $default
    ))

  proc update*(dt: DateTime, id = (0..100).rand, format = "yyyy-MM-dd"): VNode =
    result = buildHtml(
      input(
        `type` = "date",
        id = $id,
        value = dt.format(format)
      )
    )

  ########
  ### Read
  ########

  proc read*(elem: bool): VNode =
    result = buildHtml(input(`type` = "checkbox", disabled="disabled"))
    
    if elem:
      result.setAttr("checked", "true")

  proc read*(elem: bool, id: string | int): VNode =
    result = update(elem, id)
    result.setAttr("disabled", "disabled")

  proc read*(elem: VNode): VNode =
    buildHtml(elem)

  proc read*(elem: string | int | float): VNode =
    buildHtml(text(elem))

  proc read*(elem: VNode, id: string | string): VNode =
    buildHtml(elem, id = $id)

  proc read*[T](elem: string | int | float, id: string | int): VNode =
    buildHtml(text(elem), id = $id)

  proc read*(elem: enum, variant = Option, id = (0..100).rand, disabled = true): VNode =
    result = elem.update(variant = variant, id = id, disabled = disabled)

  ##########
  ### Create
  ##########

  proc create*[T: HSlice](x: T, default = 0): VNode =
    update(x, default = default)

  proc create*(elem: bool, variant = Checkbox, id = (0..100).rand): VNode =
    update(elem, variant = variant, id = id)

  proc create*(elem: string, placeholder: string, variant = Input, id = (0..100).rand): VNode =
    case(variant):
      of Input: buildHtml(input(type = "text", value = elem, placeholder = placeholder, id = $id))
      of TextArea: buildHtml(textarea(value = elem, placeholder = placeholder, id = $id))

  proc create*(elem: enum, variant = Option, id = (0..100).rand): VNode =
    let result = elem.update(variant = variant, id = id)