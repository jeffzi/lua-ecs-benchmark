import echoes.Entity;
import echoes.System;
import echoes.Echoes;

class Position {
	public var x:Float;
	public var y:Float;

	public function new(x = .0, y = .0) {
		this.x = x;
		this.y = y;
	}
}

class Velocity {
	public var x:Float;
	public var y:Float;

	public function new(x = .0, y = .0) {
		this.x = x;
		this.y = y;
	}
}

typedef Optional = Bool;
typedef Padding1 = Bool;
typedef Padding2 = Bool;
typedef Padding3 = Bool;

class MovementSystem extends System {
	private var timeElapsed:Float = 0;

	@:update private function updatePosition(position:Position, velocity:Velocity, time:Float):Void {
		position.x += velocity.x * time;
		position.y += velocity.y * time;
	}
}

class HaxeBenchmark {
	private var n_entities:Int;

	public function new(n_entities:Int) {
		Echoes.init(0);
		this.n_entities = n_entities;
	}

	public function teardown() {
		Echoes.reset();
	}
}

class CreateEmptyEntity extends HaxeBenchmark {
	public function run():Void {
		for (_ in 0...this.n_entities) {
			new Entity();
		}
	}
}

class CreateEntities extends HaxeBenchmark {
	public function run():Void {
		for (_ in 0...this.n_entities) {
			new Entity().add(new Position()).add(new Velocity());
		}
	}
}

class EntityFactory extends HaxeBenchmark {
	private var entities:Array<Entity>;

	public function new(n_entities:Int, empty:Bool = false) {
		super(n_entities);
		this.entities = new Array<Entity>();
		for (_ in 0...this.n_entities) {
			var entity = new Entity();
			if (!empty) {
				entity.add(new Position()).add(new Velocity()).add((true : Optional));
			}
			this.entities.push(entity);
		}
	}
}

class GetComponent extends EntityFactory {
	public function run():Void {
		for (entity in this.entities) {
			entity.get(Position);
		}
	}
}

class GetComponents extends EntityFactory {
	public function run():Void {
		var pos:Position;
		var velocity:Velocity;
		var opt:Optional;
		for (entity in this.entities) {
			pos = entity.get(Position);
			velocity = entity.get(Velocity);
			opt = entity.get(Optional);
		}
	}
}

class AddComponent extends EntityFactory {
	public function run():Void {
		for (entity in this.entities) {
			entity.add(new Position());
		}
	}
}

class AddComponents extends EntityFactory {
	public function run():Void {
		for (entity in this.entities) {
			entity.add(new Position()).add(new Velocity()).add((true : Optional));
		}
	}
}

class RemoveComponent extends EntityFactory {
	public function run():Void {
		for (entity in this.entities) {
			entity.remove(Position);
		}
	}
}

class RemoveComponents extends EntityFactory {
	public function run():Void {
		for (entity in this.entities) {
			entity.remove(Position).remove(Velocity).remove(Optional);
		}
	}
}

class SystemUpdate extends HaxeBenchmark {
	public function new(n_entities:Int) {
		super(n_entities);

		for (i in 0...this.n_entities) {
			var entity:Entity = new Entity().add(new Position()).add(new Velocity());
			var padding = i % 4;
			switch (padding) {
				case 1:
					entity.add((true : Padding1));
				case 2:
					entity.add((true : Padding2));
				case 3:
					entity.add((true : Padding3));
				default:
			}

			var shuffle = (i + 1) % 4;
			switch (shuffle) {
				case 0:
					entity.remove(Position);
				case 1:
					entity.remove(Velocity);
				default:
			}
		}
		new MovementSystem().activate();
	}

	public function run():Void {
		Echoes.update();
	}
}
