// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF3 to embed a chromium-based
// browser in Delphi applications.
//
// The original license of DCEF3 still applies to CEF4Delphi.
//
// For more information about CEF4Delphi visit :
//         https://www.briskbard.com/index.php?lang=en&pageid=cef
//
//        Copyright � 2017 Salvador D�az Fau. All rights reserved.
//
// ************************************************************************
// ************ vvvv Original license and comments below vvvv *************
// ************************************************************************
(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

unit uCEFClient;

{$IFNDEF CPUX64}
  {$ALIGN ON}
  {$MINENUMSIZE 4}
{$ENDIF}

{$I cef.inc}

interface

uses
  {$IFDEF DELPHI16_UP}
  WinApi.Windows,
  {$ELSE}
  Windows,
  {$ENDIF}
  uCEFBase, uCEFInterfaces, uCEFTypes;

type
  TCefClientOwn = class(TCefBaseOwn, ICefClient)
    protected
      function GetContextMenuHandler: ICefContextMenuHandler; virtual;
      function GetDialogHandler: ICefDialogHandler; virtual;
      function GetDisplayHandler: ICefDisplayHandler; virtual;
      function GetDownloadHandler: ICefDownloadHandler; virtual;
      function GetDragHandler: ICefDragHandler; virtual;
      function GetFindHandler: ICefFindHandler; virtual;
      function GetFocusHandler: ICefFocusHandler; virtual;
      function GetGeolocationHandler: ICefGeolocationHandler; virtual;
      function GetJsdialogHandler: ICefJsdialogHandler; virtual;
      function GetKeyboardHandler: ICefKeyboardHandler; virtual;
      function GetLifeSpanHandler: ICefLifeSpanHandler; virtual;
      function GetRenderHandler: ICefRenderHandler; virtual;
      function GetLoadHandler: ICefLoadHandler; virtual;
      function GetRequestHandler: ICefRequestHandler; virtual;
      function OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; virtual;

    public
      constructor Create; virtual;
  end;

  TCustomClientHandler = class(TCefClientOwn, ICefClientHandler)
    protected
      FEvents             : IChromiumEvents;
      FLoadHandler        : ICefLoadHandler;
      FFocusHandler       : ICefFocusHandler;
      FContextMenuHandler : ICefContextMenuHandler;
      FDialogHandler      : ICefDialogHandler;
      FKeyboardHandler    : ICefKeyboardHandler;
      FDisplayHandler     : ICefDisplayHandler;
      FDownloadHandler    : ICefDownloadHandler;
      FGeolocationHandler : ICefGeolocationHandler;
      FJsDialogHandler    : ICefJsDialogHandler;
      FLifeSpanHandler    : ICefLifeSpanHandler;
      FRenderHandler      : ICefRenderHandler;
      FRequestHandler     : ICefRequestHandler;
      FDragHandler        : ICefDragHandler;
      FFindHandler        : ICefFindHandler;

      function GetContextMenuHandler: ICefContextMenuHandler; override;
      function GetDialogHandler: ICefDialogHandler; override;
      function GetDisplayHandler: ICefDisplayHandler; override;
      function GetDownloadHandler: ICefDownloadHandler; override;
      function GetDragHandler: ICefDragHandler; override;
      function GetFindHandler: ICefFindHandler; override;
      function GetFocusHandler: ICefFocusHandler; override;
      function GetGeolocationHandler: ICefGeolocationHandler; override;
      function GetJsdialogHandler: ICefJsdialogHandler; override;
      function GetKeyboardHandler: ICefKeyboardHandler; override;
      function GetLifeSpanHandler: ICefLifeSpanHandler; override;
      function GetRenderHandler: ICefRenderHandler; override;
      function GetLoadHandler: ICefLoadHandler; override;
      function GetRequestHandler: ICefRequestHandler; override;
      function OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; override;
    public
      constructor Create(const events: IChromiumEvents; renderer: Boolean); reintroduce; virtual;
      procedure   Disconnect;
  end;

  TVCLClientHandler = class(TCustomClientHandler)
    protected
      function  GetMultithreadApp : boolean;
      function  GetExternalMessagePump : boolean;

    public
      constructor Create(const crm: IChromiumEvents; renderer: Boolean); reintroduce;
      destructor  Destroy; override;
      procedure   ReleaseOtherInstances;

      property  MultithreadApp          : boolean                      read GetMultithreadApp;
      property  ExternalMessagePump     : boolean                      read GetExternalMessagePump;
  end;

implementation

uses
  {$IFDEF DELPHI16_UP}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}
  uCEFMiscFunctions, uCEFLibFunctions, uCEFProcessMessage, uCEFBrowser, uCEFLoadHandler,
  uCEFFocusHandler, uCEFContextMenuHandler, uCEFDialogHandler, uCEFKeyboardHandler,
  uCEFDisplayHandler, uCEFDownloadHandler, uCEFGeolocationHandler, uCEFJsDialogHandler,
  uCEFLifeSpanHandler, uCEFRequestHandler, uCEFRenderHandler, uCEFDragHandler,
  uCEFFindHandler, uCEFConstants, uCEFApplication;

var
  looping      : Boolean = False;
  CefInstances : Integer = 0;
  CefTimer     : UINT    = 0;

function cef_client_get_context_menu_handler(self: PCefClient): PCefContextMenuHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetContextMenuHandler);
end;

function cef_client_get_dialog_handler(self: PCefClient): PCefDialogHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDialogHandler);
end;

function cef_client_get_display_handler(self: PCefClient): PCefDisplayHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDisplayHandler);
end;

function cef_client_get_download_handler(self: PCefClient): PCefDownloadHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDownloadHandler);
end;

function cef_client_get_drag_handler(self: PCefClient): PCefDragHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetDragHandler);
end;

function cef_client_get_find_handler(self: PCefClient): PCefFindHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetFindHandler);
end;

function cef_client_get_focus_handler(self: PCefClient): PCefFocusHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetFocusHandler);
end;

function cef_client_get_geolocation_handler(self: PCefClient): PCefGeolocationHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetGeolocationHandler);
end;

function cef_client_get_jsdialog_handler(self: PCefClient): PCefJsDialogHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetJsdialogHandler);
end;

function cef_client_get_keyboard_handler(self: PCefClient): PCefKeyboardHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetKeyboardHandler);
end;

function cef_client_get_life_span_handler(self: PCefClient): PCefLifeSpanHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetLifeSpanHandler);
end;

function cef_client_get_load_handler(self: PCefClient): PCefLoadHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetLoadHandler);
end;

function cef_client_get_get_render_handler(self: PCefClient): PCefRenderHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetRenderHandler);
end;

function cef_client_get_request_handler(self: PCefClient): PCefRequestHandler; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := CefGetData(GetRequestHandler);
end;

function cef_client_on_process_message_received(self: PCefClient; browser: PCefBrowser;
  source_process: TCefProcessId; message: PCefProcessMessage): Integer; stdcall;
begin
  with TCefClientOwn(CefGetObject(self)) do
    Result := Ord(OnProcessMessageReceived(TCefBrowserRef.UnWrap(browser), source_process, TCefProcessMessageRef.UnWrap(message)));
end;

constructor TCefClientOwn.Create;
begin
  inherited CreateData(SizeOf(TCefClient));

  with PCefClient(FData)^ do
    begin
      get_context_menu_handler    := cef_client_get_context_menu_handler;
      get_dialog_handler          := cef_client_get_dialog_handler;
      get_display_handler         := cef_client_get_display_handler;
      get_download_handler        := cef_client_get_download_handler;
      get_drag_handler            := cef_client_get_drag_handler;
      get_find_handler            := cef_client_get_find_handler;
      get_focus_handler           := cef_client_get_focus_handler;
      get_geolocation_handler     := cef_client_get_geolocation_handler;
      get_jsdialog_handler        := cef_client_get_jsdialog_handler;
      get_keyboard_handler        := cef_client_get_keyboard_handler;
      get_life_span_handler       := cef_client_get_life_span_handler;
      get_load_handler            := cef_client_get_load_handler;
      get_render_handler          := cef_client_get_get_render_handler;
      get_request_handler         := cef_client_get_request_handler;
      on_process_message_received := cef_client_on_process_message_received;
    end;
end;

function TCefClientOwn.GetContextMenuHandler: ICefContextMenuHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDialogHandler: ICefDialogHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDownloadHandler: ICefDownloadHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetDragHandler: ICefDragHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetFindHandler: ICefFindHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetFocusHandler: ICefFocusHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetGeolocationHandler: ICefGeolocationHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetJsdialogHandler: ICefJsDialogHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetKeyboardHandler: ICefKeyboardHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetLoadHandler: ICefLoadHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetRenderHandler: ICefRenderHandler;
begin
  Result := nil;
end;

function TCefClientOwn.GetRequestHandler: ICefRequestHandler;
begin
  Result := nil;
end;

function TCefClientOwn.OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  Result := False;
end;

// TCustomClientHandler

constructor TCustomClientHandler.Create(const events: IChromiumEvents; renderer: Boolean);
begin
  inherited Create;

  FEvents             := events;

  FLoadHandler        := TCustomLoadHandler.Create(events);
  FFocusHandler       := TCustomFocusHandler.Create(events);
  FContextMenuHandler := TCustomContextMenuHandler.Create(events);
  FDialogHandler      := TCustomDialogHandler.Create(events);
  FKeyboardHandler    := TCustomKeyboardHandler.Create(events);
  FDisplayHandler     := TCustomDisplayHandler.Create(events);
  FDownloadHandler    := TCustomDownloadHandler.Create(events);
  FGeolocationHandler := TCustomGeolocationHandler.Create(events);
  FJsDialogHandler    := TCustomJsDialogHandler.Create(events);
  FLifeSpanHandler    := TCustomLifeSpanHandler.Create(events);
  FRequestHandler     := TCustomRequestHandler.Create(events);

  if renderer then
    FRenderHandler := TCustomRenderHandler.Create(events)
   else
    FRenderHandler := nil;

  FDragHandler := TCustomDragHandler.Create(events);
  FFindHandler := TCustomFindHandler.Create(events);
end;

procedure TCustomClientHandler.Disconnect;
begin
  FEvents             := nil;
  FLoadHandler        := nil;
  FFocusHandler       := nil;
  FContextMenuHandler := nil;
  FDialogHandler      := nil;
  FKeyboardHandler    := nil;
  FDisplayHandler     := nil;
  FDownloadHandler    := nil;
  FGeolocationHandler := nil;
  FJsDialogHandler    := nil;
  FLifeSpanHandler    := nil;
  FRequestHandler     := nil;
  FRenderHandler      := nil;
  FDragHandler        := nil;
  FFindHandler        := nil;
end;

function TCustomClientHandler.GetContextMenuHandler: ICefContextMenuHandler;
begin
  Result := FContextMenuHandler;
end;

function TCustomClientHandler.GetDialogHandler: ICefDialogHandler;
begin
  Result := FDialogHandler;
end;

function TCustomClientHandler.GetDisplayHandler: ICefDisplayHandler;
begin
  Result := FDisplayHandler;
end;

function TCustomClientHandler.GetDownloadHandler: ICefDownloadHandler;
begin
  Result := FDownloadHandler;
end;

function TCustomClientHandler.GetDragHandler: ICefDragHandler;
begin
  Result := FDragHandler;
end;

function TCustomClientHandler.GetFindHandler: ICefFindHandler;
begin
  Result := FFindHandler;
end;

function TCustomClientHandler.GetFocusHandler: ICefFocusHandler;
begin
  Result := FFocusHandler;
end;

function TCustomClientHandler.GetGeolocationHandler: ICefGeolocationHandler;
begin
  Result := FGeolocationHandler;
end;

function TCustomClientHandler.GetJsdialogHandler: ICefJsDialogHandler;
begin
  Result := FJsDialogHandler;
end;

function TCustomClientHandler.GetKeyboardHandler: ICefKeyboardHandler;
begin
  Result := FKeyboardHandler;
end;

function TCustomClientHandler.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := FLifeSpanHandler;
end;

function TCustomClientHandler.GetLoadHandler: ICefLoadHandler;
begin
  Result := FLoadHandler;
end;

function TCustomClientHandler.GetRenderHandler: ICefRenderHandler;
begin
  Result := FRenderHandler;
end;

function TCustomClientHandler.GetRequestHandler: ICefRequestHandler;
begin
  Result := FRequestHandler;
end;

function TCustomClientHandler.OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  if Assigned(FEvents) then
    Result := FEvents.doOnProcessMessageReceived(browser, sourceProcess, message)
   else
    Result := False;
end;

// TVCLClientHandler

procedure TimerProc(hwnd: HWND; uMsg: UINT; idEvent: Pointer; dwTime: DWORD); stdcall;
begin
  if looping then Exit;

  if (CefInstances > 0) then
    begin
      looping := True;

      try
        cef_do_message_loop_work;
      finally
        looping := False;
      end;
    end;
end;

constructor TVCLClientHandler.Create(const crm: IChromiumEvents; renderer : Boolean);
begin
  inherited Create(crm, renderer);

  if not(MultithreadApp) and not(ExternalMessagePump) then
    begin
      if (CefInstances = 0) then CefTimer := SetTimer(0, 0, USER_TIMER_MINIMUM, @TimerProc);
      InterlockedIncrement(CefInstances);
    end;
end;

destructor TVCLClientHandler.Destroy;
begin
  try
    try
      if not(MultithreadApp) and not(ExternalMessagePump) then
        begin
          InterlockedDecrement(CefInstances);

          if (CefInstances = 0) and (CefTimer <> 0) then
            begin
              KillTimer(0, CefTimer);
              CefTimer := 0;
            end;
        end;
    except
      on e : exception do
        OutputDebugMessage('TVCLClientHandler.Destroy error: ' + e.Message);
    end;
  finally
    inherited Destroy;
  end;
end;

procedure TVCLClientHandler.ReleaseOtherInstances;
var
  i : integer;
begin
  i := pred(self.FRefCount);

  while (i >= 1) do
    begin
      self._Release;
      dec(i);
    end;
end;

function TVCLClientHandler.GetMultithreadApp : boolean;
begin
  Result := True;

  try
    if (GlobalCEFApp <> nil) then Result := GlobalCEFApp.MultiThreadedMessageLoop;
  except
    on e : exception do
      OutputDebugMessage('TVCLClientHandler.GetMultithreadApp error: ' + e.Message);
  end;
end;

function TVCLClientHandler.GetExternalMessagePump : boolean;
begin
  Result := True;

  try
    if (GlobalCEFApp <> nil) then Result := GlobalCEFApp.ExternalMessagePump;
  except
    on e : exception do
      OutputDebugMessage('TVCLClientHandler.GetExternalMessagePump error: ' + e.Message);
  end;
end;

end.
