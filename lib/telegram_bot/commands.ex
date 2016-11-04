defmodule TelegramBot.Commands do
  use TelegramBot.Module
  import TelegramBot.Util
  require Logger

  command ["start", "tama", "nya", "ping"] do
    Logger.log :warn, "== DEBUG =="
    Logger.log :debug, "msg.chat.id: #{msg.chat.id}"
    Logger.log :debug, "msg.chat.type: #{msg.chat.type}"
    Logger.log :debug, "msg.from.username: @#{msg.from.username}"
    Logger.log :debug, "msg.text: #{msg.text}"

    id = rekyuu_id
    case msg.chat.id do
      ^id -> reply "Nya ~"
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end

  command "daily" do
    id = rekyuu_id

    case msg.chat.id do
      ^id -> daily
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end

  command "draw" do
    {num, rarity} = draw

    :rand.seed(:exs1024, {num, 0, 0})

    request = "http://danbooru.donmai.us/posts.json?limit=#{Enum.random(50..100)}&page=#{Enum.random(1..3)}&tags=rating:s+order:rank" |> HTTPoison.get!
    result = Poison.Parser.parse!((request.body), keys: :atoms) |> Enum.random
    file = download "http://danbooru.donmai.us#{result.file_url}"

    post_id = Integer.to_string(result.id)
    character = result.tag_string_character |> String.split
    copyright = result.tag_string_copyright |> String.split

    {char, copy} =
      case {length(character), length(copyright)} do
        {1, _} ->
          {List.first(character)
           |> String.split("(")
           |> List.first
           |> titlecase("_"),
           List.first(copyright) |> titlecase("_")}
        {_, 1} -> {"Multiple", List.first(copyright) |> titlecase("_")}
        {_, _} -> {"Multiple", "Various"}
      end

    id = rekyuu_id
    case msg.chat.id do
      ^id -> reply_photo_with_caption file, """
        #{rarity} (#{num})

        #{char} - #{copy}
        https://danbooru.donmai.us/posts/#{post_id}
        """
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end
end
