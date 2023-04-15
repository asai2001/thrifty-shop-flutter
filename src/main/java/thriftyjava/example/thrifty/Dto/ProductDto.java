package thriftyjava.example.thrifty.Dto;


import lombok.Data;

@Data
public class ProductDto {
    String title;
    String description;
    String price;
    String imageUrl;
    String category;
}
