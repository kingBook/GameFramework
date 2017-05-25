package g.objs{
	import framework.Game;
	import framework.objs.GameObject;
	import g.MyEvent;
	import g.MyObj;
	public class Delayer extends MyObj{
		public static const EXECUTE:String = "delayerExecute";
		/**非自动的延时器，需要每次手动调用xx方法, 每次延时完成发出EXECUTE事件*/
		public static function create():Delayer{
			var game:Game=Game.getInstance();
			return game.createGameObj(new Delayer(),{}) as Delayer;
		}
		
		/**创建自动回调的延时器，每次延时完成发出EXECUTE事件,linkGameObject是否发出EXECUTE事件由odd和even决定,都为false则发出,odd==true,even==false奇数次发出，odd==false,even==true偶数次发出*/
		public static function createAutoDelayer(linkGameObject:GameObject,autoScheduleDelay:Number=1,odd:Boolean=true,even:Boolean=true):Delayer{
			var game:Game=Game.getInstance();
			var info:*={};
			info.isAuto=true;
			info.autoScheduleDelay=autoScheduleDelay;
			var delayer:Delayer=game.createGameObj(new Delayer(),info) as Delayer;
			if(odd&&even){
				delayer.addGameObject(linkGameObject);
			}else{
				if(odd)delayer.addOddGameObject(linkGameObject);
				else if(even)delayer.addEvenGameObject(linkGameObject);
			}
			return delayer;
		}
		
		/*
		{
			1:  delayer},
			1.5:delayer}
		}
		*/
		private static var list:*={};
		/**返回一个同步的延时器, 列表中的延时器在没有被引用时*/
		public static function createAutoDelayerWithList(linkGameObject:GameObject,autoScheduleDelay:Number=1,odd:Boolean=true,even:Boolean=true):Delayer{
			var delayer:Delayer=list[autoScheduleDelay];
			if(delayer){
				if(odd&&even){
					delayer.addGameObject(linkGameObject);
				}else{
					if(odd)delayer.addOddGameObject(linkGameObject);
					else if(even)delayer.addEvenGameObject(linkGameObject);
				}
			}else{
				delayer=createAutoDelayer(linkGameObject,autoScheduleDelay,odd,even);
				list[autoScheduleDelay]=delayer;
			}
			return delayer;
		}
		
		public function Delayer() {
			super();
		}
		
		private var _oddLinkGameObjects:Array=[];//奇数次运行列表
		private var _evenLinkGameObjects:Array=[];//偶数次运行列表
		private var _linkGameObjects:Array=[];
		private var _autoScheduleDelay:Number;
		private var _isAuto:Boolean;
		private var _isDelaying:Boolean;
		private var _isEven:Boolean;//是否偶数
		private var _executeEvent:MyEvent=new MyEvent(EXECUTE);
		
		override protected function init(info:*=null):void{
			_isAuto=info.isAuto;
			if(_isAuto){
				_autoScheduleDelay=info.autoScheduleDelay;
				addDelay();
			}
		}
		
		private function addDelay():void {
			scheduleOnce(delayed,_autoScheduleDelay);
		}
		
		private function delayed():void {
			_isDelaying=false;
			var isEvenDestroy:Boolean,isOddDestroy:Boolean,isDoDestroy:Boolean;
			if(_isEven){
				isEvenDestroy=dispatch(_evenLinkGameObjects);
			}else{
				isOddDestroy=dispatch(_oddLinkGameObjects);
			}
			_isEven=!_isEven;
			
			isDoDestroy=dispatch(_linkGameObjects);
			
			if(isEvenDestroy&&isOddDestroy&&isDoDestroy){
				destroy(this);
			}else{
				dispatchEvent(_executeEvent);
				if(_isAuto)addDelay();
			}
		}
		
		private function dispatch(list:Array):Boolean{
			var isDoDestroy:Boolean=true;
			for(var i:int=0;i<list.length;i++){
				var go:GameObject=list[i];
				if(!go.isDestroyed){
					isDoDestroy=false;
					go.dispatchEvent(_executeEvent);
				}
			}
			return isDoDestroy;
		}
		
		/**手动延时 delayTime<秒>*/
		public function delayHandler(delayTime:Number):void{
			if(_isDelaying)return;
			scheduleOnce(delayed,delayTime);
			_isDelaying=true;
		}
		
		override protected function onDestroyAll():void{
			list={};
			super.onDestroyAll();
		}
		
		override protected function onDestroy():void {
			unschedule(delayed);
			_executeEvent=null;
			super.onDestroy();
		}
		
		public function addOddGameObject(gameObject:GameObject):void{
			if(_oddLinkGameObjects.indexOf(gameObject)<0)
				_oddLinkGameObjects.push(gameObject);
		}
		public function addEvenGameObject(gameObject:GameObject):void{
			if(_evenLinkGameObjects.indexOf(gameObject)<0)
				_evenLinkGameObjects.push(gameObject);
		}
		public function addGameObject(gameObject:GameObject):void{
			if(_linkGameObjects.indexOf(gameObject)<0)
				_linkGameObjects.push(gameObject);
		}
		public function get isDelaying():Boolean{return _isDelaying;}
	};

}