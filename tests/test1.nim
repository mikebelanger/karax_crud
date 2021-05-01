import crud_tools
import sequtils
import times
import karax / vstyles

type
  Food = enum
    Chicken
    Beef
    Vegetarian

  IceCream = enum
    Vanilla
    Chocolate
    Strawberry

let 
  clothing = @["Shirt", "Socks", "Shoes"]
  food_special = Chicken
  some_range = 15..20
  a_time = now().utc

when defined(js):
  include karax/prelude
  import karax/[kdom]

  echo some_range.toSeq.low
  echo some_range.toSeq.high

  var new_password = ""
  var password_feedback = ""

  proc render(): VNode =
    result = 
      buildHtml(tdiv):
        true.read
        false.update
        clothing.update
        "Mike".read
        new_password.create(placeholder = "Enter new password..."):
          proc onChange(ev: Event, n: VNode) =
            let updated_password = $ev.target.value
            echo updated_password, updated_password.len
            password_feedback = case(updated_password.len):
              of 1..5: "Password too short. Must be between 6 and 12 characters"
              of 6..15: ""
              else: "Password too long.  Must be between 6 and 12 characters"
            
            new_password = updated_password

        p(style = style(StyleAttr.color, "red".cstring)):
          text password_feedback

        food_special.update
        Beef.read
        some_range.update
        some_range.update(default = 3)
        some_range.create(default = 5)
        a_time.update
        true.update(variant = Radio)
        Beef.update(variant = DataList)
        Chicken.update(variant = FieldSet)
        Beef.read(variant = DataList)
        Vanilla.create(variant = DataList, placeholder = "Enter your choice...")

  setRenderer render