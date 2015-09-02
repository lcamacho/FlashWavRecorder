package flashwavrecorder {

  import flash.display.InteractiveObject;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.MouseEvent;
  import flash.net.URLRequest;
  import flash.display.SimpleButton;
  import flash.display.Shape;
  import flash.text.TextField;
  import flash.text.TextFormat;

  import flashwavrecorder.wrappers.SecurityWrapper;

  public class Recorder extends Sprite {

    private var _recorderInterface:RecorderJSInterface;
    private var _saveButton:InteractiveObject;

    public function Recorder() {
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      var microphoneRecorder:MicrophoneRecorder = new MicrophoneRecorder();
      var panelObserver:SettingsPanelObserver = new SettingsPanelObserver(stage);
      var security:SecurityWrapper = new SecurityWrapper();
      var permissionPanel:MicrophonePermissionPanel = new MicrophonePermissionPanel(microphoneRecorder.mic,
          panelObserver, security);
      _recorderInterface = new RecorderJSInterface(microphoneRecorder, permissionPanel);

      var url:String = root.loaderInfo.parameters["upload_image"];
      if (url) {
        _saveButton = createSaveImage(url);
      } else {
        _saveButton = createSaveLink();
        ready();
      }
    }

    private function ready():void {
      addChild(_saveButton);

      _recorderInterface.saveButton = _saveButton;

      _saveButton.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
      _saveButton.visible = false;

      _recorderInterface.ready(_saveButton.width, _saveButton.height);
    }

    private function mouseReleased(event:MouseEvent):void {
      _recorderInterface.save();
    }

    private function createSaveLink():SimpleButton {
      var saveText:String = "Save";
      if (root.loaderInfo.parameters["save_text"]) {
        saveText = root.loaderInfo.parameters["save_text"];
      }
      var fontColor:Number = 0x0000EE;
      if (root.loaderInfo.parameters["font_color"]) {
        fontColor = parseInt(root.loaderInfo.parameters["font_color"], 16);
      }
      var fontSize:Number = 12;
      if (root.loaderInfo.parameters["font_size"]) {
        fontSize = parseInt(root.loaderInfo.parameters["font_size"], 10);
      }
      var backgroundColor:Number = 0x000000;
      if (root.loaderInfo.parameters["background_color"]) {
        backgroundColor = parseInt(root.loaderInfo.parameters["background_color"], 16);
      }
      var formatText:TextFormat = new TextFormat();
      formatText.color = fontColor;
      formatText.size = fontSize;
      formatText.bold = true;

      var textField:TextField = new TextField();
      textField.name = "textField";
      textField.mouseEnabled = false;
      textField.text = saveText;
      textField.setTextFormat(formatText);
      textField.y = (30 - fontSize) / 2;
      textField.width = 60;
      textField.autoSize = "center";

      var rectangleShape:Shape = new Shape();
      rectangleShape.graphics.beginFill(parseInt(root.loaderInfo.parameters["background_color"], 16));
      rectangleShape.graphics.drawRect(0, 0, 60, 30);
      rectangleShape.graphics.endFill();

      var simpleButtonSprite:Sprite = new Sprite();
      simpleButtonSprite.name = "simpleButtonSprite";
      simpleButtonSprite.addChild(rectangleShape);
      simpleButtonSprite.addChild(textField);

      var simpleButton:SimpleButton = new SimpleButton();
      simpleButton.upState = simpleButtonSprite;
      simpleButton.overState = simpleButtonSprite;
      simpleButton.downState = simpleButtonSprite;
      simpleButton.hitTestState = simpleButtonSprite;

      return simpleButton;
    }

    private function createSaveImage(url:String):Sprite {
      var image:Sprite = new Sprite();
      var loader:Loader = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageCompleteHandler);
      loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageIoErrorHandler);
      loader.load(new URLRequest(url));
      image.addChild(loader);
      image.buttonMode = true;
      return image;
    }

    private function imageCompleteHandler(event:Event):void {
      ready();
    }

    private function imageIoErrorHandler(event:Event):void {
      _saveButton = createSaveLink();
      ready();
    }
  }

}
