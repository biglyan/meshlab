#include "EqHandle.h"

EqHandle::EqHandle()
{
	_barHeight = 100;
	setSize(5);

	QPointF a(-_size/2,-_size);
	QPointF b(_size/2, -_size);
	QPointF c(0, -1.87f*_size);

	_triangle.append(QLineF(a,b));
	_triangle.append(QLineF(b,c));
	_triangle.append(QLineF(c,a));
}

EqHandle::~EqHandle(void)
{
}


void EqHandle::paint ( QPainter * painter, const QStyleOptionGraphicsItem * option, QWidget * widget /*= 0*/ )
{
	Q_UNUSED(option);
	Q_UNUSED(widget);
	//QPen pen(Qt::black);
	//non sepen.setWidth(2);
	painter->setPen(_color);
	painter->setBrush(_color);
	painter->drawLine(0, -_size, 0, -_barHeight);

	painter->drawLines(_triangle);
	painter->drawRect(-_size/2, -_size, _size, _size);
}

QRectF EqHandle::boundingRect () const
{
	return QRectF(-_size/2, -_barHeight, _size, _barHeight);
}

void EqHandle::mouseMoveEvent(QGraphicsSceneMouseEvent *event)
{
	setCursor(Qt::OpenHandCursor);


	QPointF newPos = event->scenePos();
	if ( (newPos.x() < _chartInfo->leftBorder) || (newPos.x() > _chartInfo->rightBorder) )
		return;

	QPointF oldPos = pos();
	qreal handleOffset = newPos.x()-oldPos.x();
	if (handleOffset<0)
		handleOffset = -handleOffset;

	/* for testing only
	qreal leftx = _handlesPointer[LEFT_HANDLE].pos().x();
	qreal midx =  _handlesPointer[MID_HANDLE].pos().x();
	qreal rightx= _handlesPointer[RIGHT_HANDLE].pos().x();
	*/
	

	if (handleOffset >= std::numeric_limits<float>::epsilon())
	{
		

		switch (_type)
		{
		case MID_HANDLE:
			if ( (newPos.x() > _handlesPointer[LEFT_HANDLE].pos().x()) && (newPos.x() < _handlesPointer[RIGHT_HANDLE].pos().x()) )
			{
				*_midHandlePercentilePosition = calculateMidHandlePercentilePosition(newPos.x());
				moveMidHandle();
				emit positionChanged(); // for gammaCorrectionLabel
			}
			break;
		case LEFT_HANDLE:
			if (newPos.x() < _handlesPointer[RIGHT_HANDLE].pos().x()) 
			{
				setPos(newPos.x(), oldPos.y());
				// calculating new spinbox value
				qreal newSpinboxValue = calculateSpinBoxValueFromHandlePosition(pos().x());
				// Changing minimum/maximum value of opposite spinbox
				_handlesPointer[RIGHT_HANDLE]._spinBoxPointer->setMinimum(newSpinboxValue);
				// Emitting signals to spinbox and mid handle
				_spinBoxPointer->blockSignals(true);
				emit positionChangedToSpinBox((double)newSpinboxValue);
				_spinBoxPointer->blockSignals(false);
				emit positionChanged();  // for redrawing transferFunctionScene and moving mid equalizerHistogram Handle
				
			}
			break;
		case RIGHT_HANDLE:
			if (newPos.x() > _handlesPointer[LEFT_HANDLE].pos().x()) 
			{
				setPos(newPos.x(), oldPos.y());
				qreal newSpinboxValue = calculateSpinBoxValueFromHandlePosition(pos().x());
				_handlesPointer[LEFT_HANDLE]._spinBoxPointer->setMaximum(newSpinboxValue);
				_spinBoxPointer->blockSignals(true);
				emit positionChangedToSpinBox((double)newSpinboxValue);
				_spinBoxPointer->blockSignals(false);
				emit positionChanged();
			}
			break;
		}

		
	}
	
}

void EqHandle::moveMidHandle()
{
	assert(_type==MID_HANDLE);
	qreal newPosX = _handlesPointer[LEFT_HANDLE].pos().x() + *_midHandlePercentilePosition * (_handlesPointer[RIGHT_HANDLE].pos().x() - _handlesPointer[LEFT_HANDLE].pos().x());
	setPos(newPosX, pos().y());
	qreal newSpinboxValue = calculateSpinBoxValueFromHandlePosition(newPosX);

	_spinBoxPointer->blockSignals(true);
	emit positionChangedToSpinBox((double)newSpinboxValue);
	_spinBoxPointer->blockSignals(false);

}


void EqHandle::setXBySpinBoxValueChanged(double spinBoxValue)
{
	qreal percentageValue = (spinBoxValue -  _chartInfo->minX) / (_chartInfo->maxX - _chartInfo->minX);
	qreal newHandleX = percentageValue * _chartInfo->chartWidth + _chartInfo->leftBorder;

	qreal handleOffset = newHandleX-pos().x();
	if (handleOffset<0)
		handleOffset = -handleOffset;
	// this control avoid counter invoking (?)
	if (handleOffset < std::numeric_limits<float>::epsilon())
		return;

	switch (_type)
	{
	case MID_HANDLE:
		if ( (newHandleX > _handlesPointer[LEFT_HANDLE].pos().x()) && (newHandleX < _handlesPointer[RIGHT_HANDLE].pos().x()) )
		{
			*_midHandlePercentilePosition = calculateMidHandlePercentilePosition(newHandleX);
			moveMidHandle();
		}
		break;
	case LEFT_HANDLE:
		if (newHandleX < _handlesPointer[RIGHT_HANDLE].pos().x()) 
		{
			setPos(newHandleX, pos().y());
			_handlesPointer[RIGHT_HANDLE]._spinBoxPointer->setMinimum(spinBoxValue);
			emit positionChanged();
		}
		break;
	case RIGHT_HANDLE:
		if (newHandleX > _handlesPointer[LEFT_HANDLE].pos().x()) 
		{
			setPos(newHandleX, pos().y());
			_handlesPointer[LEFT_HANDLE]._spinBoxPointer->setMaximum(spinBoxValue);
			emit positionChanged();
		}		
		break;
	}
}
