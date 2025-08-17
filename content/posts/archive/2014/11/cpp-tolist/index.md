---
title: "Определение по списку в C++"
date: 2014-11-18T16:38:00.001Z
draft: false
tags: ["archive"]
# filename: "cpp-tolist"
# catigories: []
---

В PHP есть возможность присвоить переменным значения, используя массив:

```php
list($a, $b) = array('str1', 'str2');
```

В Python это выглядит так:

```python
a, b = ['str1', 'str2']
```

А вот в C++ такой языковой конструкции нет. Но это совершенно не проблема, потому что ее можно сделать самому.

Вот что у меня получилось:

```cpp
/**
 * This is a helper class.
 * It can be used only inside the function ListInitializer tolist(Args&& ...args)
 * ListInitializer list(Args&& ...args)
 * In all other cases, use it not possible
 * size is the number of arguments with which the constructor was called
 */
template<typename DataType, unsigned size>
class ListInitializer
{
public:

    /**
     * Assignment operator
     * Ref-qualified forbids such things:
     * ListInitializer c(a,b);
     * c = arr;
     * You can only use this form:
     * ListInitializer(a,b) = arr;
     * VecType must be convertable to DataType
     */
    template<typename ContainerType>
    ListInitializer& operator=(ContainerType&& arr) &&
    {
        auto it = arr.begin(), itend = arr.end();
        unsigned i = 0;
        while(it != itend && i < size) {
            *parr[i] = *it;
            ++it;
            ++i;
        }
        return *this;
    }

    /**
     * Deleted constructors. Forbids such things:
     * tolist q(a,b,c,d,e),w(a,b,c,d,e);
     * w = q;
     * You can only use this form:
     * tolist(a,b,c,d,e) = arr;
     */
    ListInitializer(const ListInitializer& that) = delete;
    ListInitializer() = delete;

private:
    /**
     * Constructor with one argument
     */
    explicit ListInitializer(DataType& arg)
    {
        helper(0, arg);
    }

    /**
     * Constructor with a variable (>1) number of arguments
     * You can use any number of arguments of type DataType in the constructor.
     * tolist(a,b,c,d) = arr;
     * tolist(a,b) = arr;
     */
    template<typename... Args>
    ListInitializer(DataType& arg0, Args&... args)
    {
        helper(0, arg0, args...);
    }

    /**
     * Move constructor
     */
    ListInitializer(ListInitializer&& that)
    {
        for(unsigned i = 0; i < size; ++i) {
            parr[i] = that.parr[i];
            that.parr[i] = nullptr;
        }
    }

    /**
     * Helper method.
     * Allows to initialize the list of any number of arguments.
     * Alternately, one by one makes pointers to the arguments into the internal array.
     */
    template<typename... Args>
    void helper(int ind, DataType& arg0, Args&... args)
    {
        helper(ind, arg0);
        helper(++ind, args...);
    }

    /**
     * Helper method.
     */
    void helper(int ind, DataType& arg0)
    {
        parr[ind] = &arg0;
    }

    template<typename T, typename... Args>
    friend ListInitializer<T, sizeof...(Args)+1> tolist(T& arg0, Args&... args);

    // Internal array of pointers to pointers to arguments
    DataType* parr[size];
};

template<typename DataType, typename... Args>
ListInitializer<DataType, sizeof...(Args)+1> tolist(DataType& arg0, Args&... args)
{
    return ListInitializer<DataType, sizeof...(Args)+1>(arg0, args...);
}

// Check
#include <iostream>
#include <vector>
int main()
{

    std::vector<std::string> arr{"str1", "str2", "str3", "str4", "str5", "str6"};
    std::string a, b, c, d, e;

    tolist(b) = arr;
    std::cout << std::endl << a << " " << b << " " << c << " " << d << " " << e << std::endl;

    tolist(a, b, c, d, e) = arr;
    std::cout << std::endl << a << " " << b << " " << c << " " << d << " " << e << std::endl;

    return 0;
}

/*
 * g++ tolist.cpp -std=c++11 && ./a.out
 * or 
 * clang++ tolist.cpp -std=c++11 && ./a.out
 *
 * |output:
 * | str1
 * |
 * |str1 str2 str3 str4 str5
 *
 */
```

Нужен C++11, т.к. используются Ref-qualifiers.

P.S. blogger.com как всегда портит код. Надо менять блогодвижок.

