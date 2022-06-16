[Setting name="Show counter"]
bool showCounter = true;

enum SpeedType
{
    Metric,
    Imperial,
}

[Setting name="Speed Type"]
SpeedType selectedSpeedType = SpeedType::Metric;

[Setting name="Display Kilometers/Miles instead of meters/yards"]
bool km = true;

[Setting name="Anchor X position" min=0 max=1]
float anchorX = .95;

[Setting name="Anchor Y position" min=0 max=1]
float anchorY = .95;

[Setting name="Font size" min=8 max=72]
int fontSize = 24;

bool inGame = false;
bool isOnServer = false;

float distance = 0;

void RenderMenu() {
    if (UI::MenuItem("\\$f50" + Icons::Map + "\\$z Distance Counter", "", showCounter)) {
        if (isOnServer){
            UI::ShowNotification("Distance Counter - I'm sorry","The distance counter does not work on server. Please enable it on solo.", 5000);
        } else {
            showCounter = !showCounter;
        }
    }
}

void Render() {
  if(showCounter && inGame && !isOnServer) {
        nvg::FontSize(fontSize);
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        if (selectedSpeedType == SpeedType::Imperial) {
            if (km){
                nvg::TextBox(anchorX * Draw::GetWidth() - 100, anchorY * Draw::GetHeight(), 200, Text::Format("%.2f", (distance/1000)/1.609) + " mi");
            } else {
                nvg::TextBox(anchorX * Draw::GetWidth() - 100, anchorY * Draw::GetHeight(), 200, Text::Format("%.0f", distance*1.094) + " y");
            }
        }
        if (selectedSpeedType == SpeedType::Metric) {
            if (km){
                nvg::TextBox(anchorX * Draw::GetWidth() - 100, anchorY * Draw::GetHeight(), 200, Text::Format("%.2f", distance/1000) + " km");
            } else {
                nvg::TextBox(anchorX * Draw::GetWidth() - 100, anchorY * Draw::GetHeight(), 200, Text::Format("%.0f", distance) + " m");
            }
        }
    }
}

void Update(float dt) {
  if(cast<CSmArenaClient>(GetApp().CurrentPlayground) !is null) {
        CSmArenaClient@ playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
        if(cast<CSmArenaClient>(GetApp().CurrentPlayground).GameTerminals.Length <= 0
        || cast<CSmArenaClient>(GetApp().CurrentPlayground).GameTerminals[0].UISequence_Current != SGamePlaygroundUIConfig::EUISequence::Playing
        || cast<CSmPlayer>(cast<CSmArenaClient>(GetApp().CurrentPlayground).GameTerminals[0].GUIPlayer) is null
        || cast<CSmArenaClient>(GetApp().CurrentPlayground).Arena is null) {
            inGame = false;
            return;
        }
        CSmPlayer@ player = cast<CSmPlayer>(cast<CSmArenaClient>(GetApp().CurrentPlayground).GameTerminals[0].GUIPlayer);
        CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
        if (!inGame) {
            distance = 0;
        }

        auto network = cast<CTrackManiaNetwork>(GetApp().Network);
        auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
        isOnServer = serverInfo.JoinLink != "";

        if (!isOnServer){
            distance = playerScriptAPI.Distance;
        } else {
            distance = 0;
        }

        inGame = true;

    } else {
        inGame = false;
        return;
    }
}
