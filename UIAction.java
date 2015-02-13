import java.io.File;

public interface UIAction {
  public void execute();
}

interface UIFileParamAction {
  public void execute(File param);
}

class Wrapper<T> {
  public T val;
  Wrapper(T v) {val = v;}
}
