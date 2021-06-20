module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Json.Decode as Json
import Random exposing (Generator)
import Time

type Drop = None | Near | Far | VeryFar

type alias Row = List Drop

type alias Model = List Row

type Msg = NewRow Row | Tick

type alias Flags =
    { width : Int
    , height : Int
    }

main : Program Json.Value Model Msg
main =
    Browser.element
       { init = init
       , view = view
       , update = update
       , subscriptions = subscriptions
       }

subscriptions : Model -> Sub Msg
subscriptions _ = Time.every 100 <| always Tick

init : Json.Value -> (Model, Cmd Msg)
init flags =
    let
        flagsD =
            Json.map2 Tuple.pair
                (Json.field "width" Json.int)
                (Json.field "height" Json.int)
        ( width, height ) =
            Maybe.withDefault (10, 5)
                <| Result.toMaybe
                <| Json.decodeValue flagsD flags
    in
        ( empty width height
        , Cmd.none
        )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewRow row -> (push row model, Cmd.none)
        Tick -> (model, Random.generate NewRow <| rowG <| rowWidth model)

view : Model -> Html a
view model =
    Html.div
        [ style "white-space" "pre"
        , style "font-family" "mono"
        , class "rain"
        ]
        <| List.indexedMap (viewRow <| visibleWidth model) model

viewRow : Int -> Int -> Row -> Html a
viewRow w i drops =
    Html.div [] <| List.map viewDrop <| List.take w <| List.drop i drops

viewDrop : Drop -> Html a
viewDrop drop =
    let
        att =
            case drop of
                None -> []
                Near -> [class "raindrop-near"]
                Far -> [class "raindrop-far"]
                VeryFar -> [class "raindrop-very-far"]
        inner =
            case drop of
                None -> " "
                _ -> "/"
    in Html.span att [ Html.text inner ]

empty : Int -> Int -> List Row
empty w h =
    List.repeat h <| List.repeat (w + h) None

push : Row -> List Row -> List Row
push row rows = row :: List.take (List.length rows - 1) rows

rowWidth : List Row -> Int
rowWidth rows =
    case rows of
        [] -> 0
        (row :: _) -> List.length row

visibleWidth : List Row -> Int
visibleWidth rows = rowWidth rows - List.length rows

rowG : Int -> Generator Row
rowG w =
    Random.list w
        <| Random.uniform
            Near
            [ Far, Far
            , VeryFar, VeryFar
            , None, None, None, None, None
            ]
