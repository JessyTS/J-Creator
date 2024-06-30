RegisterServerEvent('rCreator:CreateIdentity')
AddEventHandler('rCreator:CreateIdentity', function(Identity, session)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  local zgeg = xPlayer.getIdentifier(source)
  local timestamp = math.floor(Identity.dateOfBirth / 1000)
  local date = os.date('%d/%m/%Y', timestamp)
  local Data, Data2, Data3 = {}, {}, {}
  local un, deux, trois, quatre, cinq, six, sept, huit, neuf, dix

    if xPlayer ~= nil then
      MySQL.Async.execute('UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
        ['@firstname'] = Identity.firstName,
        ['@lastname'] = Identity.lastName,
        ['@dateofbirth'] = date,
        ['@sex'] = Identity.sex,
        ['@height']	= Identity.cut
      }, function(rowsChanged)
        MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
          ["@identifier"] = xPlayer.getIdentifier()
        }, function(userData)
          Data = userData
          for k,v in pairs(Data) do
            un = v.firstname
            deux = v.lastname
            trois = v.dateofbirth
            quatre = v.sex
            cinq = v.height
            six = v.id
          end
          SetTimeout(200, function()
            MySQL.Async.fetchAll('SELECT * FROM ts_vip WHERE identifier = @identifier', {
              ['@identifier'] = xPlayer.getIdentifier()
            }, function (result_)
              Data2 = result_
              for a,b in pairs(Data2) do
                sept = b.VIPID
              end
              SetTimeout(200, function()
                MySQL.Async.fetchAll('SELECT * FROM ts_boutique WHERE identifier = @identifier', {
                  ['@identifier'] = xPlayer.getIdentifier()
                }, function(result)
                  Data3 = result
                  for c,d in pairs(Data3) do
                    huit = d.Boutique_ID
                  end
                  SetTimeout(200, function()
                    JessyTS_Webhook("Un Nouveau joueur est en ville !!\n", "ID FiveM : "..zgeg.."\nID Session : "..session.."\nID Unique : "..six.."\nID Boutique : "..huit.."\nID VIP : "..sept.."\n\nPrénom : "..un.."\nNom : "..deux.."\nDate de naissance : "..trois.."\nSexe : "..quatre.."\nTaille : "..cinq.." cm\nDate de Création : "..os.date('%H:%M:%S | %d/%m/%Y').."\n\nATTENTION C'EST PEUT-ETRE UN TROLEUR !", Creator.WebHook, "Logs Créator")
                    JessyTS_Webhook_ping("<@&1233751564833918976>", Creator.WebHook, "Logs Créator")
                    Jessy_Notif_xPlayer(source, 'far fa-check-circle text-success', 'Mboka FA', '', 'Bienvenue à Los Santos', 5000)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end
end)

RegisterServerEvent("rCreator:setPlayerToBucket")
AddEventHandler("rCreator:setPlayerToBucket", function(id)
  SetPlayerRoutingBucket(source, id)
end)

RegisterServerEvent("rCreator:setPlayerToNormalBucket")
AddEventHandler("rCreator:setPlayerToNormalBucket", function()
  SetPlayerRoutingBucket(source, 0)
end)

function JessyTS_Webhook(debut, message, link, name)
  local avatar = 'https://cdn.discordapp.com/attachments/1145882151095652382/1239280638918393876/mboka.png?ex=665e0909&is=665cb789&hm=3bb2f18b722b36882bfb8a8fbddd53130583c5047d4ad9b551a4fbf70aaa1330&'
  local DiscordWebHook = link
  local color = 2061822
  local name = name
  local embeds = {
      {
          ["title"] = name,
          ["description"] = debut..'\n```'..message..'```\n'.."Temps : <t:".. math.floor(tonumber(os.time())) ..":R>",
          ["type"] = "rich",
          ["color"] = color,
          ["footer"] =  {
              ["text"] = 'TS-Script | MbokaRP',
          },
      }
  }

  if message == nil or message == '' then 
      return FALSE
  end
  PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({avatar_url = avatar, username = name, embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

function JessyTS_Webhook_ping(message, link, name)
  local avatar = 'https://cdn.discordapp.com/attachments/1145882151095652382/1239280638918393876/mboka.png?ex=665e0909&is=665cb789&hm=3bb2f18b722b36882bfb8a8fbddd53130583c5047d4ad9b551a4fbf70aaa1330&'
  local DiscordWebHook = link
  local name = name
  local embeds = message

  if message == nil or message == '' then 
      return FALSE
  end
  PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({avatar_url = avatar, username = name, content = embeds}), { ['Content-Type'] = 'application/json' })
end

function Jessy_Notif(icon, appname, title, message, time)
  TriggerClientEvent('Jessy_ATA:show', source, icon, appname, title, message, time)
end

function Jessy_Notif_xPlayer(source, icon, appname, title, message, time)
  TriggerClientEvent('Jessy_ATA:show', source, icon, appname, title, message, time)
end