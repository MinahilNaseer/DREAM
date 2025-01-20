import 'package:flame/components.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flame/events.dart';

class DraggableTile extends SpriteComponent with DragCallbacks {
  final String tileName; 
  final Function(DraggableTile) onDropOnPlaceholder;
  final SpriteComponent missingTilePlaceholder; 
  final Vector2 initialPosition; 
  bool isDragging = false;

  DraggableTile({
    required this.tileName,
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
    required this.onDropOnPlaceholder,
    required this.missingTilePlaceholder,
  })  : initialPosition = position.clone(), 
        super(sprite: sprite, size: size, position: position);

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isDragging) {
      position.add(event.delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;

    
    if ((position - missingTilePlaceholder.position).length < 50) {
      onDropOnPlaceholder(this); 
    } else {
      
      resetPosition();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    isDragging = false;
    resetPosition();
  }

  void resetPosition() {
    
    position.setFrom(initialPosition);
  }
}
