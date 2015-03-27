import java.util.ArrayList;

class Wrapper<T> {
  private T val;

  Wrapper(T v) {
    val = v;
  }

  void value(T v) {
    val = v;
  }
  T value() {
    return val;
  }
}

class EventWrapper<T> extends Wrapper<T> {
  ArrayList<Delegate<Boolean, T>> setEvents;
  ArrayList<Delegate<Boolean, T>> getEvents;

  EventWrapper(T i) {
    super(i);
    setEvents = new ArrayList();
    getEvents = new ArrayList();
  }

  void addSetWatcher(Delegate<Boolean, T> e) {
    setEvents.add(e);
  }

  void addGetWatcher(Delegate<Boolean, T> e) {
    getEvents.add(e);
  }

  void value(T v) {
    for (Delegate<Boolean, T> d : setEvents) {
      d.execute(v);
    }
    super.value(v);
  }

  T value() {
    for (Delegate<Boolean, T> d : setEvents) {
      d.execute(super.value());
    }
    return super.value();
  }
}

