using Pkg
Pkg.add("PlotlyJS")
using PlotlyJS Plots
plotlyjs()

a=rand(1:100,30)
b=rand(1:100,30)
c=rand(1:100,30)

##Original visualization
data=hcat(a,b,c)
Plots.scatter(a,b,c)
plot!(a,b,c)

##Distance between two points regardless of dimension
function distance_any(x,y)
    return sqrt(sum((x-y) .^2))
end

##Creating distance matrix for path
function distance_matrix(list)
    N=length(list[:,1])
    mat=zeros(N,N) 
    for i in 1:N
        for j in 1:N
            mat[i,j]=distance_any(list[i,:],list[j,:])
        end
    end
    for i in 1:N
        mat[i,i]=Inf
    end
    return mat
end

##Path cost from distance matrix
function path_cost_from_distance_matrix(dist_m,path)
    cost=0
    for i in path
        cost+=dist_m[path[i],path[i+1]]
    end
    
    return cost
end

##Two-opt operations
function two_opt_change(route, v1, v2) 
    
    new_route=zeros(length(route))
    
    new_route[1:v1]=route[1:v1]
    
    new_route[v1+1:v2]=reverse(route[v1+1:v2])
  
    new_route[v2+1:end]=route[v2+1:end]
    
    return Int.(new_route)
end

##all_plots is to keep the specific paths during the optimization function
all_plots=[]
function two_opt(path)
    new_distance=Inf
    best_distance = path_cost_from_distance_matrix(test_matrix,path)
    present_route=path

   for k in 1:10000
        for i in 1:length(path)-2
            
            for j in i+1:length(path)-1
                
                new_route = two_opt_change(present_route,i,j)
                
                new_distance = path_cost_from_distance_matrix(test_matrix,new_route)
                diff=abs(best_distance-new_distance)
                if (new_distance < best_distance) 
                    println(new_distance)
                    present_route = new_route
                    push!(all_plots,present_route)
                    best_distance = new_distance
                end
            end
        end
    end
        return best_distance,present_route
end

##Points from path for visualization
function graphing_path(path)
    
    x=[]
    y=[]
    z=[]
    
    push!(x,data[path[1],1])
    push!(y,data[path[1],2])
    push!(z,data[path[1],3])
    
    for i in 2:length(path)-1
        push!(x,data[path[i],1])
        push!(y,data[path[i],2])
        push!(z,data[path[i],3])
    end
    
    push!(x,data[path[1],1])
    push!(y,data[path[1],2])
    push!(z,data[path[1],3])
    
    return x,y,z
end

x,y,z=graphing_path(best_path)
Plots.scatter(a,b,c)
p=plot!(x,y,z,legend=false)
