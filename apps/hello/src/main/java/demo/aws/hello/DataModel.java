package demo.aws.hello;

public class DataModel {
    private String data;

    public DataModel() {
    }

    public DataModel(String foo) {
        this.data = foo;
    }

    public String getData() {
        return this.data;
    }

    public void setData(String data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "Foo1 [foo=" + this.data + "]";
    }
}
