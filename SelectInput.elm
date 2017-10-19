port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, on, onClick)
import String
import Basics exposing (..)
import List exposing (..)

{-
Example latex 
\(x^2 + y^2 = z^2\)
-}
port toJs : String -> Cmd msg
port toElm : (String -> msg) -> Sub msg

main =
  Html.program
    { view = view
    , update = update
    , init = init
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init  =
  ( Model MathML "", Cmd.none
  )



-- MODEL


type alias Model =
  { mathType: MathType,
    message: String
  }

type  MathType =
         MathML
        | Latex
        | Tex

valuesWithLabels : List ( MathType, String )
valuesWithLabels =
  [ ( MathML, "MathML" )
  , ( Latex, "Latex" )
  , ( Tex, "Tex" )
  ]

-- often this can be replaced with `toString`
toOptionString : MathType -> String
toOptionString currency =
  case currency of
    MathML -> "MathML"
    Latex -> "Latex"
    Tex -> "Tex"

fromOptionString : String -> MathType
fromOptionString string =
  case string of
    "MathML" -> MathML
    "Latex" -> Latex
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
  | SendToJs String
  | UpdateStr String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MathTypeChange newMathType ->
      ({ model | mathType =  fromOptionString newMathType }, Cmd.none)
    
    SendToJs str ->
        ( model, toJs str)
    UpdateStr str ->
            ( { model | message = str }, Cmd.none )

-- VIEW
{--------------HTML----------------------------------------}
view : Model -> Html Msg
view model =
  div []
    [ 
     infoHeader,
     select
        [ onInput MathTypeChange
        ]
        [ viewOption MathML
        , viewOption Latex
        , viewOption Tex
        ],
     textarea [ placeholder "get changed", onInput SendToJs ] [],
     button [ onClick (SendToJs "testing")] [text "send Info"],
     p [id "MathTextElm"] [text "The answer you provided is: ${}$."],
     p [] [text model.message],
     infoFooter
    ]

infoHeader : Html msg
infoHeader = 
    header []
           [h1 [] [text "Math Convert"] ]

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
  toElm UpdateStr

{-----------end-SubScriptions----------------------------------------}