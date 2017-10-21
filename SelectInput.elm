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

main =
  Html.program
    { view = view
    , update = update
    , init = init
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init  =
  ( Model Tex "" "", Cmd.none
  )



-- MODEL


type alias Model =
  { mathType: MathType,
    linkedMathEquation: String,
    mathEquation: String
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


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MathTypeChange newMathType ->
      ({ model | mathType =  fromOptionString newMathType }, Cmd.none)
    
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
{-

 -}
-- VIEW
{--------------HTML----------------------------------------}
view : Model -> Html Msg
view model =
  div []
    [ 
     infoHeader,
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
     p[][text model.linkedMathEquation],
     div[id "SvgContainer"][
       p [id "AsciiMathEquation",hidden (AsciiMath /= model.mathType) ] [text "Ascii `` "], 
       p [id "TexEquation",hidden (Tex /= model.mathType)] [text "Tex ${}$ "], 
       p [id "MathMLEquation",hidden (MathML /= model.mathType)] [text ""] 
     ],
     
     -- ``
     -- ${}$
     infoFooter
    ]



infoHeader : Html msg
infoHeader = 
    header []
           [h1 [] [text "Math"],
            h1 [] [text "Equations"] ]

infoFooter : Html msg
infoFooter =
    footer [ class "info" ]
        [ p [] [ text " Stuff " ]
        , p []
            [ text "Written by "
            , a [ href "https://github.com/evancz" ] [ text "Evan Czaplicki" ]
            ]
        , p []
            [ text "Part of "
            , a [ href "http://todomvc.com" ] [ text "TodoMVC" ]
            ]
        ]
{--------------HTML----------------------------------------}

{--------------SubScriptions----------------------------------------}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch[
    updatingLinkedMathEquation SetLinkedMathEquation
    ,updatingMathEquation UpdateEquaion
  ]
  

{-----------end-SubScriptions----------------------------------------}