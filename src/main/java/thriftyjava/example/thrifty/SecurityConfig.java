package thriftyjava.example.thrifty;


import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    private CorsConfigurationSource configurationSource() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        config.addAllowedOrigin("*");
        config.addAllowedHeader(config.ALL);
        config.addAllowedMethod(config.ALL);
        source.registerCorsConfiguration("/**", config);
        return source;
    }
    //uncomment when deploy to heroku

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable();

        //uncomment when deploy to heroku
//        http.cors().configurationSource(configurationSource()).and()
//                .requiresChannel()
//                .anyRequest()
//                .requiresSecure();
        //uncomment when deploy to Heroku
    }
}