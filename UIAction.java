import java.io.File;

public interface UIAction {
  public void execute();
}

interface UIFileParamAction {
  public void execute(File param);
}

