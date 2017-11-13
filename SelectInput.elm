port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, onClick)
import String
import Basics exposing (..)
import List exposing (..)
import Json.Encode exposing (encode, Value, string, int, float, bool, list, object)

{-
Example latex 
\(x^2 + y^2 = z^2\)

Ports
https://hackernoon.com/how-elm-ports-work-with-a-picture-just-one-25144ba43cdd
https://guide.elm-lang.org/interop/javascript.html

First convert elm to js
- elm-make SelectInput.elm --output=SelectInput.js

Second change extension to html

-}
port reloadEquaion : String -> Cmd msg
port updateEquaion : String -> Cmd msg
port sumitEquation : String -> Cmd msg
port updatingLinkedMathEquation : (String -> msg) -> Sub msg
port updatingMathEquation : (String -> msg) -> Sub msg
port updateErrorMessage : (String -> msg) -> Sub msg

main =
  Html.program
    { view = view
    , update = update
    , init = init
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init  =
  ( Model Tex "" "" "" False, Cmd.none
  )



-- MODEL


type alias Model =
  { mathType: MathType,
    linkedMathEquation: String,
    mathEquation: String,
    errorMessage: String,
    helpPageOpen: Bool
  }

type  MathType =
         MathML
        | AsciiMath
        | Tex

encodeModel : Model -> Value
encodeModel model =
  Json.Encode.object
    [ ("mathType",Json.Encode.string  (toOptionString model.mathType) )
    , ("linkedMathEquation", Json.Encode.string model.linkedMathEquation)
    , ("mathEquation", Json.Encode.string model.mathEquation)
    ]
--("mathType", toOptionString model.mathType) 
    
    

valuesWithLabels : List ( MathType, String )
valuesWithLabels =
  [ ( MathML, "MathML" )
  , ( AsciiMath, "AsciiMath" )
  , ( Tex, "Tex" )
  ]

-- often this can be replaced with `toString`
toOptionString : MathType -> String
toOptionString currency =
  case currency of
    MathML -> "MathML"
    AsciiMath -> "AsciiMath"
    Tex -> "Tex"

fromOptionString : String -> MathType
fromOptionString string =
  case string of
    "MathML" -> MathML
    "AsciiMath" -> AsciiMath
    "Tex" -> Tex
    _ -> Tex



viewOption : MathType -> Html Msg
viewOption mathType =
  option
    [ value <| toString mathType ]
    [ text <| toString mathType ]


{--------------Update----------------------------------------}
type Msg
  = MathTypeChange String
  | ReloadEquaion 
  | SumitEquation
  | SetLinkedMathEquation String
  | UpdateEquaion String
  | ToggleHelpPage Bool 
  | UpdateErrorMessage String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MathTypeChange newMathType ->
        let
            newModel = { model |  mathType = fromOptionString newMathType }
        in
          (newModel, updateEquaion (encode 0 (encodeModel newModel) ))
    
    -- event to reload the id
    ReloadEquaion ->
        ( model, reloadEquaion "reload")

    -- event to submit equaion
    -- needs equation
    -- id of the image -- mathEquation
    SumitEquation ->
        ( model, sumitEquation (encode 0 (encodeModel model) ) )
     -- ("{\"linkedMathEquation\": \"" ++ model.linkedMathEquation ++ "\",\"mathEquation\": \"" ++ model.mathEquation ++ "\"}") 
    -- event to send string
    -- update
    UpdateEquaion str-> 
        let
            newModel = { model |  mathEquation = str }
        in
            
        (newModel, updateEquaion  (encode 0 (encodeModel newModel) ) )
    --mathEquation =  str,

    SetLinkedMathEquation str ->
        ({ model | linkedMathEquation =  str}, Cmd.none)
      
    ToggleHelpPage bool ->
      ({ model | helpPageOpen = bool}, Cmd.none)
    
    UpdateErrorMessage string ->
      ({ model | errorMessage = string}, Cmd.none)
{-

 -}
-- VIEW
{--------------HTML----------------------------------------}
view : Model -> Html Msg
view model =
  div [ id "elmContainer"]
    [ 
     infoHeader,
     div [id "siteMainContent"] [
        select
        [ onInput MathTypeChange, id "selectMathType"
        ]
        [ viewOption Tex
        , viewOption MathML
        , viewOption AsciiMath
       
        ],
        textarea [id "textAreaMathEquation", placeholder "get changed", onInput UpdateEquaion, value model.mathEquation] [ ],
        div [] [
            button [id "submitMathEquation", onClick SumitEquation] [text "submit"] , 
            --button [ onClick (SendToJs "testing")] [text "send Info"],
            div [ id "reloadContainer"] [
                button [onClick ReloadEquaion ] [text "reload"],
                button [onClick (SetLinkedMathEquation ""), hidden (String.isEmpty model.linkedMathEquation)] [text "unconnect"]
            ]
        ],
        div[id "SvgContainer"] [
          p [id "AsciiMathEquation",hidden (AsciiMath /= model.mathType) ] [text "Ascii `` "], 
          p [id "TexEquation",hidden (Tex /= model.mathType)] [text "Tex ${}$ "], 
          div[hidden (MathML /= model.mathType)][
            p [] [text "MathML"],
            p [id "MathMLEquation"] [text ""] 
          ]
        ],
        div[id "ErrorMessage", hidden(String.isEmpty model.errorMessage), onClick (UpdateErrorMessage "")] [
          p[] [text ("Error - " ++ model.errorMessage) ]
        ]
     ],
     
     helpPage model,
     -- ``
     -- ${}$
     infoFooter
    ]

myStyle : Attribute msg
myStyle =
  style
    [ ("backgroundColor", "red")
    , ("height", "90px")
    , ("width", "100%")
    ]

helpPageStyles: Bool -> Attribute msg
helpPageStyles bool = 
    if(bool == True)
    then
      style
      [ ("transform", "scale(1,1)")
      ]
    else
      style
      [ ("transform", "scale(1,0)")
      ]



helpPage : Model -> Html Msg
helpPage model = 
    div [id "helpPage", helpPageStyles model.helpPageOpen]
           [
            h2 [] [text "Help Page",span [id "exitIcon", onClick (ToggleHelpPage False) ] [text " X"]],
            h3 [] [text "Create an Equation"],
            p [] [text ("To create an image out of your equation you must first select the type of format your math equation is in.  Then type your equation inside the " ++
                  "text box.  Right underneath the text box will be a example of the output.  Once you are done hit the submit button and it will create a image of the " ++
                  "equation")],
            h3 [] [text "Updating Equation"],
            p [] [text ("To update an image select the image you want and hit the reload icon.  This will bind the image to the extension and whenever you hit the" ++
                        " button it will update the image.  To stop updating a image hit the unconnect button.")],
            img [id "logo" , src "https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/96x96.png?raw=true"] []
           ]


infoHeader : Html Msg
infoHeader = 
    header []
           [h1 [] [text "<Math>"],
            h1 [] [text "</Equations>"],
            img [id "helpIcon", onClick (ToggleHelpPage True) , src "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBTdmcgVmVjdG9yIEljb25zIDogaHR0cDovL3d3dy5vbmxpbmV3ZWJmb250cy5jb20vaWNvbiAtLT4KPCFET0NUWVBFIHN2ZyBQVUJMSUMgIi0vL1czQy8vRFREIFNWRyAxLjEvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkIj4KPHN2ZyBvbmNsaWNrPSJ0b2dnbGVIZWxwUGFnZSgpIiBpZD0iaGVscEljb24iIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHZpZXdCb3g9IjAgMCAxMDAwIDEwMDAiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDEwMDAgMTAwMCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+CjxtZXRhZGF0YT4gU3ZnIFZlY3RvciBJY29ucyA6IGh0dHA6Ly93d3cub25saW5ld2ViZm9udHMuY29tL2ljb24gPC9tZXRhZGF0YT4KPGc+PHBhdGggZD0iTTUwMC4xLDkuOUMyMjkuNCw5LjksMTAsMjI5LjEsMTAsNDk5LjhjMCwyNzAuNywyMTkuNCw0OTAuMyw0OTAuMSw0OTAuM1M5OTAsNzcwLjUsOTkwLDQ5OS44Qzk5MCwyMjkuMSw3NzAuNyw5LjksNTAwLjEsOS45eiBNNTAwLjMsODc5LjJjLTIwOS41LDAtMzc5LjYtMTY5LjktMzc5LjYtMzc5LjVjMC0yMDkuNCwxNzAtMzc5LDM3OS42LTM3OWMyMDkuMiwwLDM3OSwxNjkuNiwzNzksMzc5Qzg3OS4yLDcwOS40LDcwOS41LDg3OS4yLDUwMC4zLDg3OS4yeiIvPjxwYXRoIGQ9Ik00NTcuNyw2NDUuNWg5M3YtNzIuN2MwLTE5LjYsOS4yLTM4LDMzLjgtNTQuMmMyNC4zLTE2LjEsOTIuNy00OC42LDkyLjctMTM0LjFjMC04NS43LTcxLjgtMTQ0LjctMTMyLTE1Ny4yYy02MC41LTEyLjUtMTI1LjktNC4zLTE3Mi4xLDQ2LjVjLTQxLjYsNDUuMy01MC4zLDgxLjUtNTAuMywxNjAuOWg5M3YtMTguNmMwLTQyLjEsNC45LTg2LjksNjUuNC05OS4xYzMzLTYuNyw2NCwzLjgsODIuMywyMS42YzIxLjEsMjAuNiwyMS4xLDY2LjctMTIuMyw4OS45bC01Mi41LDM1LjVjLTMwLjYsMTkuOC00MC45LDQxLjYtNDAuOSw3My43VjY0NS41TDQ1Ny43LDY0NS41eiIvPjxwYXRoIGQ9Ik01MDQuMyw2ODEuOWMyNi4zLDAsNDcuOCwyMS40LDQ3LjgsNDcuOWMwLDI2LjUtMjEuNSw0Ny44LTQ3LjgsNDcuOGMtMjYuNiwwLTQ4LjMtMjEuNC00OC4zLTQ3LjhDNDU2LjEsNzAzLjMsNDc3LjcsNjgxLjksNTA0LjMsNjgxLjl6Ii8+PC9nPgo8L3N2Zz4="] [],
            img [id "logo" , src "https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/96x96.png?raw=true"] []
             ]

infoFooter : Html Msg
infoFooter =
    footer [ class "info" ]
        [ p []
            [ text "Code at ",
            a [ href "https://github.com/brendena/MathEquationsGoogleSlide", target "blank"] [ text "Github Repo / For Bug Reports" ]
            ]
        , p []
            [ a [ href "mailto:bafeaturerequest@gmail.com?Subject=Bug%20or%20Feature" ] [ text "Message me" ]
            , text " at bafeaturerequest@gmail.com"
            ]
        ]
{--------------HTML----------------------------------------}

{--------------SubScriptions----------------------------------------}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch[
      updatingLinkedMathEquation SetLinkedMathEquation
    , updatingMathEquation UpdateEquaion
    , updateErrorMessage UpdateErrorMessage
  ]
  

{-----------end-SubScriptions----------------------------------------}