package g.objs{
	import flash.display.DisplayObject;
	import framework.Game;
	import framework.objs.GameObject;
	import g.MyData;
	
	public class AlphaTo extends GameObject{
		
		public static function create(disObj:DisplayObject,alphaInit:Number=1,alphaTarget:Number=0,duration:Number=1,
		updateFunc:Function=null,updateParams:Array=null,completeFunc:Function=null,completeParams:Array=null):AlphaTo{
			var game:Game=Game.getInstance();
			var info:*={};
			info.disObj=disObj;
			info.alphaInit=alphaInit;
			info.alphaTarget=alphaTarget;
			info.duration=duration;
			info.updateFunc=updateFunc;
			info.updateParams=updateParams;
			info.completeFunc=completeFunc;
			info.completeParams=completeParams;
			return game.createGameObj(new AlphaTo(),info) as AlphaTo;
		}
		
		public function AlphaTo(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_disObj=info.disObj;
			_alphaInit=info.alphaInit;
			_alphaTarget=info.alphaTarget;
			_duration=info.duration;
			_updateFunc=info.updateFunc;
			_updateParams=info.updateParams;
			_completeFunc=info.completeFunc;
			_completeParams=info.completeParams;
			
			_v=(_alphaTarget-_alphaInit)/(_duration*MyData.frameRate);
			_disObj.alpha=_alphaInit;
			
		}
		
		override protected function update():void{
			_disObj.alpha+=_v;
			if(_v>0){
				if(_disObj.alpha>=_alphaTarget){
					_disObj.alpha=_alphaTarget;
					if(_completeFunc!=null) _completeFunc.apply(null,_completeParams);
					destroy(this);
				}else{
					if(_updateFunc!=null) _updateFunc.apply(null,_updateParams);
				}
			}else if(_v<0){
				if(_disObj.alpha<=_alphaTarget){
					_disObj.alpha=_alphaTarget;
					if(_completeFunc!=null) _completeFunc.apply(null,_completeParams);
					destroy(this);
				}else{
					if(_updateFunc!=null) _updateFunc.apply(null,_updateParams);
				}
			}
		}
		
		private var _v:Number;
		
		private var _disObj:DisplayObject;
		private var _alphaInit:Number;
		private var _alphaTarget:Number;
		private var _duration:Number;
		private var _updateFunc:Function;
		private var _updateParams:Array;
		private var _completeFunc:Function;
		private var _completeParams:Array;
		
	};

}