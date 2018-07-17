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


port updatingMathEquationColor : (String -> msg) -> Sub msg


port updatingMathEquation : (String -> msg) -> Sub msg


port updateErrorMessage : (String -> msg) -> Sub msg


main =
    Html.program
        { view = view
        , update = update
        , init = init
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model Tex "" "" "" "#000000" False SizeMedium
    , Cmd.none
    )



-- MODEL


type alias Model =
    { mathType : MathType
    , linkedMathEquation : String
    , mathEquation : String
    , errorMessage : String
    , mathEquationColor : String
    , helpPageOpen : Bool
    , sizeEquation : SizeEquation
    }


type MathType
    = MathML
    | AsciiMath
    | Tex

type SizeEquation
    = SizeSmall
    | SizeMedium
    | SizeLarge


encodeModel : Model -> Value
encodeModel model =
    Json.Encode.object
        [ ( "mathType", Json.Encode.string (toOptionString model.mathType) )
        , ( "linkedMathEquation", Json.Encode.string model.linkedMathEquation )
        , ( "mathEquation", Json.Encode.string model.mathEquation )
        , ( "mathEquationColor", Json.Encode.string model.mathEquationColor )
        , ( "mathEquationSize", Json.Encode.string (toSizeEquation model.sizeEquation ) ) 
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
        MathML ->
            "MathML"

        AsciiMath ->
            "AsciiMath"

        Tex ->
            "Tex"

toSizeEquation : SizeEquation  -> String
toSizeEquation sizeEquat =
    case sizeEquat of
        SizeSmall ->
            "0"
        SizeMedium ->
            "1"
        SizeLarge ->
            "2"




fromOptionString : String -> MathType
fromOptionString string =
    case string of
        "MathML" ->
            MathML

        "AsciiMath" ->
            AsciiMath

        "Tex" ->
            Tex

        _ ->
            Tex


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
    | UpdateMathEquation String
    | UpdateSizeEquation SizeEquation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MathTypeChange newMathType ->
            let
                newModel =
                    { model | mathType = fromOptionString newMathType }
            in
                ( newModel, updateEquaion (encode 0 (encodeModel newModel)) )

        -- event to reload the id
        ReloadEquaion ->
            ( model, reloadEquaion "reload" )

        -- event to submit equaion
        -- needs equation
        -- id of the image -- mathEquation
        SumitEquation ->
            ( model, sumitEquation (encode 0 (encodeModel model)) )

        -- ("{\"linkedMathEquation\": \"" ++ model.linkedMathEquation ++ "\",\"mathEquation\": \"" ++ model.mathEquation ++ "\"}")
        -- event to send string
        -- update
        UpdateEquaion str ->
            let
                newModel =
                    { model | mathEquation = str }
            in
                ( newModel, updateEquaion (encode 0 (encodeModel newModel)) )

        --mathEquation =  str,
        SetLinkedMathEquation str ->
            ( { model | linkedMathEquation = str }, Cmd.none )

        ToggleHelpPage bool ->
            ( { model | helpPageOpen = bool }, Cmd.none )

        UpdateErrorMessage string ->
            ( { model | errorMessage = string }, Cmd.none )

        UpdateMathEquation colorChanged ->
            ( { model | mathEquationColor = colorChanged }, Cmd.none )

        UpdateSizeEquation sizeEquationUpdate ->
            ( { model | sizeEquation = sizeEquationUpdate }, Cmd.none )


{-

-}
-- VIEW
{--------------HTML----------------------------------------}


view : Model -> Html Msg
view model =
    div [ id "elmContainer" ]
        [ infoHeader
        , div [ id "siteMainContent" ]
            [ select
                [ onInput MathTypeChange, id "selectMathType" ]
                [ viewOption Tex
                , viewOption MathML
                , viewOption AsciiMath
                ]
            , div [ id "colorSelectContainer" ]
                [ span []
                    [ text ("") ]
                , input [ id "selectColor", type_ "color", onInput UpdateMathEquation, value model.mathEquationColor, placeholder "select a color needs to be in #FFFFFF format" ] []
                , img [ id "iconColorPalett", src iconColorPalette, classList [ ( "iconInButton", True ) ] ] []
                ]
            , div [ id "sizeSelectContainer" ]
                [
                      button [onClick (UpdateSizeEquation SizeSmall), classList [ ( "iconSizeButton", True ), ( "iconSizeButtonSelected", model.sizeEquation == SizeSmall ) ]] [ text "Small" ]
                    , button [onClick (UpdateSizeEquation SizeMedium), classList [ ( "iconSizeButton", True ), ( "iconSizeButtonSelected", model.sizeEquation == SizeMedium ) ]] [ text "Medium" ]
                    , button [onClick (UpdateSizeEquation SizeLarge), classList [ ( "iconSizeButton", True ), ( "iconSizeButtonSelected", model.sizeEquation == SizeLarge ) ]] [ text "Large" ]
                ]
            , textarea [ id "textAreaMathEquation", onInput UpdateEquaion, value model.mathEquation, placeholder "Equation code placeholder" ] []
            , div []
                [ button [ id "submitMathEquation", onClick SumitEquation ]
                    [ span [] [ text ("add to slide") ]
                    , img [ src iconCopy, classList [ ( "iconInButton", True ) ] ] []
                    ]
                , --button [ onClick (SendToJs "testing")] [text "send Info"],
                  div [ id "reloadContainer" ]
                    [ button [ onClick ReloadEquaion ]
                        [ span [] [ text ("Connect to Equation") ]
                        , img [ src iconFullLink, classList [ ( "iconInButton", True ) ] ] []
                        ]
                    , button [ onClick (SetLinkedMathEquation ""), hidden (String.isEmpty model.linkedMathEquation) ]
                        [ span [] [ text "Disconnect from Equation" ]
                        , img [ src iconBrokenLink, classList [ ( "iconInButton", True ) ] ] []
                        ]
                    ]
                ]
            , div [ id "SvgContainer" ]
                [ p [ id "AsciiMathEquation", hidden (AsciiMath /= model.mathType) ] [ text "Ascii `` " ]
                , p [ id "TexEquation", hidden (Tex /= model.mathType) ] [ text "Tex ${}$ " ]
                , div [ hidden (MathML /= model.mathType) ]
                    [ p [] [ text "MathML" ]
                    , p [ id "MathMLEquation" ] [ text "" ]
                    ]
                ]
            , div [ id "ErrorMessage", hidden (String.isEmpty model.errorMessage), onClick (UpdateErrorMessage "") ]
                [ p [] [ text ("Error - " ++ model.errorMessage) ]
                ]
            ]
        , helpPage model
        , infoFooter
        ]


myStyle : Attribute msg
myStyle =
    style
        [ ( "backgroundColor", "red" )
        , ( "height", "90px" )
        , ( "width", "100%" )
        ]


helpPageStyles : Bool -> Attribute msg
helpPageStyles bool =
    if (bool == True) then
        style
            [ ( "transform", "translateX(0)" )
            ]
    else
        style
            [ ( "transform", "translateX(100%)" )
            ]


helpPage : Model -> Html Msg
helpPage model =
    div [ id "helpPage", helpPageStyles model.helpPageOpen ]
        [ h2 [] [ text "Help Page", span [ id "exitIcon", onClick (ToggleHelpPage False) ] [ text " X" ] ]
        , h3 [] [ text "Create an Equation" ]
        , img [ id "logo", src logoIconSrc ] []
        , p [ classList [ ( "indentText", True ) ] ]
            [ text
                ("To create an image out of your equation you must first select the type of format your math equation is in.  Then type your equation inside the "
                    ++ "text box.  Right underneath the text box will be a example of the output.  Once you are done hit the submit button and it will create a image of the "
                    ++ "equation"
                )
            ]
        , h3 [] [ text "Updating Equation" ]
        , p [ classList [ ( "indentText", True ) ] ]
            [ text
                ("To update an image select the image you want and hit the reload icon.  This will bind the image to the extension and whenever you hit the"
                    ++ " button it will update the image.  To stop updating a image hit the unconnect button."
                )
            ]
        , h3 [] [ text ("UI Elements") ]
        , div []
            [ div []
                [ img [ src iconCopy, classList [ ( "iconInButton", True ) ] ] []
                , span [] [ text ("Copy to clipboard") ]
                , p [ classList [ ( "indentText", True ) ] ] [ text ("The 'copy to clipboard' button takes the equation's image and loads it into the current slide.") ]
                ]
            , div []
                [ img [ src iconColorPalette, classList [ ( "iconInButton", True ) ] ] []
                , span [] [ text ("Color Equation") ]
                , p [ classList [ ( "indentText", True ) ] ] [ text ("Next to the color pallet will be a box with a color.  Click this to edit what color is used for the equation.  Only on submission will this color actually visible.  This is to make the equation most visible on white background.") ]
                ]
            , div []
                [ img [ src iconFullLink, classList [ ( "iconInButton", True ) ] ] []
                , span [] [ text ("Edit old equation") ]
                , p [ classList [ ( "indentText", True ) ] ] [ text ("To edit a equation that's in image form you must first load the equation text into the text area.  To do this click the image in the slide, then click the 'Load Equation' button.  This will load the equation and link it to the extension.  Now every time you 'add image to slide' this will update the equation.  To stop updating a equation you must hit the the 'Unconnect Equation' button. ") ]
                ]
            , div []
                [ img [ src iconBrokenLink, classList [ ( "iconInButton", True ) ] ] []
                , span [] [ text ("Unconnected equation") ]
                , p [ classList [ ( "indentText", True ) ] ] [ text ("If the equation is connected you should see the 'Unconnected equation' button.  This disconnecteds the current equation and will allow you to create a new image. ") ]
                ]
            ]
        ]


infoHeader : Html Msg
infoHeader =
    header []
        [ h1 [] [ text "<Math>" ]
        , h1 [] [ text "</Equations>" ]
        , img [ id "helpIcon", onClick (ToggleHelpPage True), src iconHelp ] []
        , img [ id "logo", src logoIconSrc ] []
        ]


infoFooter : Html Msg
infoFooter =
    footer [ class "info" ]
        [ p []
            [ text "Code at "
            , a [ href "https://github.com/brendena/MathEquationsGoogleSlide", target "blank" ] [ text "Github Repo / For Bug Reports" ]
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
    Sub.batch
        [ updatingLinkedMathEquation SetLinkedMathEquation
        , updatingMathEquation UpdateEquaion
        , updateErrorMessage UpdateErrorMessage
        , updatingMathEquationColor UpdateMathEquation
        ]



{-----------end-SubScriptions----------------------------------------}
{-----------------------Images----------------}


iconFullLink : String
iconFullLink =
    "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48IURPQ1RZUEUgc3ZnIFBVQkxJQyAiLS8vVzNDLy9EVEQgU1ZHIDEuMS8vRU4iICJodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQiPjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI1MTJweCIgaGVpZ2h0PSI1MTJweCIgdmlld0JveD0iMCAwIDUxMiA1MTIiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDUxMiA1MTIiIHhtbDpzcGFjZT0icHJlc2VydmUiPjxwYXRoIGZpbGw9IiMwMTAxMDEiIGQ9Ik00NTkuNjU0LDIzMy4zNzNsLTkwLjUzMSw5MC41Yy00OS45NjksNTAtMTMxLjAzMSw1MC0xODEsMGMtNy44NzUtNy44NDQtMTQuMDMxLTE2LjY4OC0xOS40MzgtMjUuODEzbDQyLjA2My00Mi4wNjNjMi0yLjAxNiw0LjQ2OS0zLjE3Miw2LjgyOC00LjUzMWMyLjkwNiw5LjkzOCw3Ljk4NCwxOS4zNDQsMTUuNzk3LDI3LjE1NmMyNC45NTMsMjQuOTY5LDY1LjU2MywyNC45MzgsOTAuNSwwbDkwLjUtOTAuNWMyNC45NjktMjQuOTY5LDI0Ljk2OS02NS41NjMsMC05MC41MTZjLTI0LjkzOC0yNC45NTMtNjUuNTMxLTI0Ljk1My05MC41LDBsLTMyLjE4OCwzMi4yMTljLTI2LjEwOS0xMC4xNzItNTQuMjUtMTIuOTA2LTgxLjY0MS04Ljg5MWw2OC41NzgtNjguNTc4YzUwLTQ5Ljk4NCwxMzEuMDMxLTQ5Ljk4NCwxODEuMDMxLDBDNTA5LjYyMywxMDIuMzQyLDUwOS42MjMsMTgzLjM4OSw0NTkuNjU0LDIzMy4zNzN6IE0yMjAuMzI2LDM4Mi4xODZsLTMyLjIwMywzMi4yMTljLTI0Ljk1MywyNC45MzgtNjUuNTYzLDI0LjkzOC05MC41MTYsMGMtMjQuOTUzLTI0Ljk2OS0yNC45NTMtNjUuNTYzLDAtOTAuNTMxbDkwLjUxNi05MC41YzI0Ljk2OS0yNC45NjksNjUuNTQ3LTI0Ljk2OSw5MC41LDBjNy43OTcsNy43OTcsMTIuODc1LDE3LjIwMywxNS44MTMsMjcuMTI1YzIuMzc1LTEuMzc1LDQuODEzLTIuNSw2LjgxMy00LjVsNDIuMDYzLTQyLjA0N2MtNS4zNzUtOS4xNTYtMTEuNTYzLTE3Ljk2OS0xOS40MzgtMjUuODI4Yy00OS45NjktNDkuOTg0LTEzMS4wMzEtNDkuOTg0LTE4MS4wMTYsMGwtOTAuNSw5MC41Yy00OS45ODQsNTAtNDkuOTg0LDEzMS4wMzEsMCwxODEuMDMxYzQ5Ljk4NCw0OS45NjksMTMxLjAzMSw0OS45NjksMTgxLjAxNiwwbDY4LjU5NC02OC41OTRDMjc0LjU2MSwzOTUuMDkyLDI0Ni40MiwzOTIuMzQyLDIyMC4zMjYsMzgyLjE4NnoiLz48L3N2Zz4="


iconBrokenLink : String
iconBrokenLink =
    "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/PjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4PSIwcHgiIHk9IjBweCIgdmlld0JveD0iMCAwIDIxLjgzNCAyMS44MzQiIHN0eWxlPSJlbmFibGUtYmFja2dyb3VuZDpuZXcgMCAwIDIxLjgzNCAyMS44MzQ7IiB4bWw6c3BhY2U9InByZXNlcnZlIj48Zz48cGF0aCBzdHlsZT0iZmlsbDojMDkwNjA5OyIgZD0iTTE0LjY3NCwzLjcxNWgwLjM1N3YzLjIwMmgtMC4zNTdWMy43MTV6IE0xNS4wMzEsNy40NTNoMy4yMDF2MC4zNThoLTMuMjAxVjcuNDUzeiBNNy4zLDE1Ljg4N2gwLjM1N3YzLjIwMUg3LjNWMTUuODg3eiBNNC4wOTgsMTQuOTkzSDcuM3YwLjM1OEg0LjA5OFYxNC45OTN6IE04LjY1MSwxMS45MTNsLTUuNzctNS43NjljLTAuODY5LTAuODY5LTAuODY3LTIuMjgxLDAtMy4xNDljMC4wMTQtMC4wMTMsMC4wMzktMC4wNCwwLjAzOS0wLjA0czAuMDUzLTAuMDUsMC4wNzgtMC4wNzZDMy44NjUsMi4wMTIsNS4yNzYsMi4wMTIsNi4xNDQsMi44OGw2LjAwMSw2LjAwMWwtMC4wMDIsMC4wMDJjMCwwLDAuMDQsMC4wMzksMC4xMTgsMC4xMTdsMC4yODEtMC44OTZsMC45MjQtMC4xNzRsMC4wMzctMC44NDRMNy43MiwxLjMwNWMtMS43MzktMS43MzktNC41Ni0xLjc0LTYuMjk4LTAuMDAyYy0wLjAxOCwwLjAxOC0wLjA0MSwwLjA0LTAuMDU4LDAuMDU5QzEuMzQyLDEuMzgxLDEuMzI3LDEuMzk4LDEuMzA2LDEuNDE5Yy0xLjc0LDEuNzM5LTEuNzQsNC41NTksMCw2LjI5OUw3LjEsMTMuNTEyYzAuMDcyLDAuMDcyLDAuMTMsMC4xMzIsMC4xNzksMC4xOGwtMC4wMDEsMC4wMDFsMC4xMzcsMC4xMzhsMC4yNzMtMC44NzNsMC45MjQtMC4xNzVMOC42NTEsMTEuOTEzeiBNMjAuNTI4LDE0LjExNWwtNS43NjItNS43NTlsLTAuMDMyLDAuNzY5TDEzLjcwMSw5LjMybC0wLjI2NywwLjg1Mmw1LjUyLDUuNTJjMC44NjcsMC44NjgsMC44NjUsMi4yNzktMC4wMDEsMy4xNDdjLTAuMDE1LDAuMDEzLTAuMDM5LDAuMDQtMC4wMzksMC4wNHMtMC4wNTMsMC4wNTEtMC4wNzgsMC4wNzdjLTAuODY2LDAuODY2LTIuMjc4LDAuODY2LTMuMTQ2LTAuMDAybC01Ljc3My01Ljc3M2wtMC4wMzUsMC43OTdsLTEuMDMzLDAuMTk1bC0wLjI2LDAuODMxbDUuNTI2LDUuNTI1YzEuNzM5LDEuNzM5LDQuNTYsMS43NDEsNi4yOTgsMC4wMDNjMC4wMTktMC4wMiwwLjA0MS0wLjA0MSwwLjA1OS0wLjA2MWMwLjAyMS0wLjAxOSwwLjAzNi0wLjAzNiwwLjA1OC0wLjA1N0MyMi4yNjgsMTguNjc2LDIyLjI2OCwxNS44NTYsMjAuNTI4LDE0LjExNXoiLz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PC9zdmc+"


iconHelp : String
iconHelp =
    "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBTdmcgVmVjdG9yIEljb25zIDogaHR0cDovL3d3dy5vbmxpbmV3ZWJmb250cy5jb20vaWNvbiAtLT4KPCFET0NUWVBFIHN2ZyBQVUJMSUMgIi0vL1czQy8vRFREIFNWRyAxLjEvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkIj4KPHN2ZyBvbmNsaWNrPSJ0b2dnbGVIZWxwUGFnZSgpIiBpZD0iaGVscEljb24iIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHZpZXdCb3g9IjAgMCAxMDAwIDEwMDAiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDEwMDAgMTAwMCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+CjxtZXRhZGF0YT4gU3ZnIFZlY3RvciBJY29ucyA6IGh0dHA6Ly93d3cub25saW5ld2ViZm9udHMuY29tL2ljb24gPC9tZXRhZGF0YT4KPGc+PHBhdGggZD0iTTUwMC4xLDkuOUMyMjkuNCw5LjksMTAsMjI5LjEsMTAsNDk5LjhjMCwyNzAuNywyMTkuNCw0OTAuMyw0OTAuMSw0OTAuM1M5OTAsNzcwLjUsOTkwLDQ5OS44Qzk5MCwyMjkuMSw3NzAuNyw5LjksNTAwLjEsOS45eiBNNTAwLjMsODc5LjJjLTIwOS41LDAtMzc5LjYtMTY5LjktMzc5LjYtMzc5LjVjMC0yMDkuNCwxNzAtMzc5LDM3OS42LTM3OWMyMDkuMiwwLDM3OSwxNjkuNiwzNzksMzc5Qzg3OS4yLDcwOS40LDcwOS41LDg3OS4yLDUwMC4zLDg3OS4yeiIvPjxwYXRoIGQ9Ik00NTcuNyw2NDUuNWg5M3YtNzIuN2MwLTE5LjYsOS4yLTM4LDMzLjgtNTQuMmMyNC4zLTE2LjEsOTIuNy00OC42LDkyLjctMTM0LjFjMC04NS43LTcxLjgtMTQ0LjctMTMyLTE1Ny4yYy02MC41LTEyLjUtMTI1LjktNC4zLTE3Mi4xLDQ2LjVjLTQxLjYsNDUuMy01MC4zLDgxLjUtNTAuMywxNjAuOWg5M3YtMTguNmMwLTQyLjEsNC45LTg2LjksNjUuNC05OS4xYzMzLTYuNyw2NCwzLjgsODIuMywyMS42YzIxLjEsMjAuNiwyMS4xLDY2LjctMTIuMyw4OS45bC01Mi41LDM1LjVjLTMwLjYsMTkuOC00MC45LDQxLjYtNDAuOSw3My43VjY0NS41TDQ1Ny43LDY0NS41eiIvPjxwYXRoIGQ9Ik01MDQuMyw2ODEuOWMyNi4zLDAsNDcuOCwyMS40LDQ3LjgsNDcuOWMwLDI2LjUtMjEuNSw0Ny44LTQ3LjgsNDcuOGMtMjYuNiwwLTQ4LjMtMjEuNC00OC4zLTQ3LjhDNDU2LjEsNzAzLjMsNDc3LjcsNjgxLjksNTA0LjMsNjgxLjl6Ii8+PC9nPgo8L3N2Zz4="


iconCopy : String
iconCopy =
    "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48IURPQ1RZUEUgc3ZnIFBVQkxJQyAiLS8vVzNDLy9EVEQgU1ZHIDEuMS8vRU4iICJodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQiPjxzdmcgdmVyc2lvbj0iMS4xIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB4PSIwcHgiIHk9IjBweCIgdmlld0JveD0iMCAwIDEwMDAgMTAwMCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgMTAwMCAxMDAwIiB4bWw6c3BhY2U9InByZXNlcnZlIj48bWV0YWRhdGE+IFN2ZyBWZWN0b3IgSWNvbnMgOiBodHRwOi8vd3d3Lm9ubGluZXdlYmZvbnRzLmNvbS9pY29uIDwvbWV0YWRhdGE+PGc+PHBhdGggZD0iTTY5MSwxNjAuOFYxMEgyNjkuNUMyMDYuMyw3Mi42LDE0My4xLDEzNS4yLDgwLDE5Ny44djY0MS40aDIyNy45Vjk5MEg5MjBWMTYwLjhINjkxeiBNMjY5LjUsNjQuNHYxMzQuNEgxMzMuMUMxNzguNSwxNTQsMjI0LDEwOS4yLDI2OS41LDY0LjR6IE0zMDcuOSw4MDEuMkgxMTcuNVYyMzYuOGgxOTAuNVY0Ny45aDM0NC41djExMi45aC0xNTRjLTYzLjUsNjIuOS0xMjcsMTI1LjktMTkwLjUsMTg4LjhWODAxLjJ6IE00OTkuNSwyMTUuMnYxMzQuNUgzNjMuMXYtMWM0NS4xLTQ0LjUsOTAuMi04OSwxMzUuMy0xMzMuNUw0OTkuNSwyMTUuMnogTTg4MS41LDk1MmgtNTM1VjM4Ni42SDUzOFYxOTguOGgzNDMuNVY5NTJ6Ii8+PC9nPjwvc3ZnPg=="


iconColorPalette : String
iconColorPalette =
    "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/PjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+PHN2ZyB2ZXJzaW9uPSIxLjEiIGlkPSJDYXBhXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4IiB3aWR0aD0iNDU5cHgiIGhlaWdodD0iNDU5cHgiIHZpZXdCb3g9IjAgMCA0NTkgNDU5IiBzdHlsZT0iZW5hYmxlLWJhY2tncm91bmQ6bmV3IDAgMCA0NTkgNDU5OyIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PGc+PGcgaWQ9InBhbGV0dGUiPjxwYXRoIGQ9Ik0yMjkuNSwwQzEwMiwwLDAsMTAyLDAsMjI5LjVTMTAyLDQ1OSwyMjkuNSw0NTljMjAuNCwwLDM4LjI1LTE3Ljg1LDM4LjI1LTM4LjI1YzAtMTAuMi0yLjU1LTE3Ljg1LTEwLjItMjUuNWMtNS4xLTcuNjUtMTAuMi0xNS4zLTEwLjItMjUuNWMwLTIwLjQsMTcuODUxLTM4LjI1LDM4LjI1LTM4LjI1aDQ1LjljNzEuNCwwLDEyNy41LTU2LjEsMTI3LjUtMTI3LjVDNDU5LDkxLjgsMzU3LDAsMjI5LjUsMHogTTg5LjI1LDIyOS41Yy0yMC40LDAtMzguMjUtMTcuODUtMzguMjUtMzguMjVTNjguODUsMTUzLDg5LjI1LDE1M3MzOC4yNSwxNy44NSwzOC4yNSwzOC4yNVMxMDkuNjUsMjI5LjUsODkuMjUsMjI5LjV6IE0xNjUuNzUsMTI3LjVjLTIwLjQsMC0zOC4yNS0xNy44NS0zOC4yNS0zOC4yNVMxNDUuMzUsNTEsMTY1Ljc1LDUxUzIwNCw2OC44NSwyMDQsODkuMjVTMTg2LjE1LDEyNy41LDE2NS43NSwxMjcuNXogTTI5My4yNSwxMjcuNWMtMjAuNCwwLTM4LjI1LTE3Ljg1LTM4LjI1LTM4LjI1UzI3Mi44NSw1MSwyOTMuMjUsNTFzMzguMjUsMTcuODUsMzguMjUsMzguMjVTMzEzLjY1LDEyNy41LDI5My4yNSwxMjcuNXogTTM2OS43NSwyMjkuNWMtMjAuNCwwLTM4LjI1LTE3Ljg1LTM4LjI1LTM4LjI1UzM0OS4zNSwxNTMsMzY5Ljc1LDE1M1M0MDgsMTcwLjg1LDQwOCwxOTEuMjVTMzkwLjE1LDIyOS41LDM2OS43NSwyMjkuNXoiLz48L2c+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjxnPjwvZz48Zz48L2c+PGc+PC9nPjwvc3ZnPg=="


logoIconSrc : String
logoIconSrc =
    "https://github.com/brendena/MathEquationsGoogleSlide/blob/master/image/logoNoBackground64by64.png?raw=true"
